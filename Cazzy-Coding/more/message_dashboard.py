#!/usr/bin/env python3
"""
Unified Messaging Architecture
Author: Cazandra Aporbo
Version: 2.0.0; Updated 11/1/2025

Integrates email systems with distributed chat storage using Apache Cassandra.
Provides unified access to team communications, direct messages, and email threads
with advanced features including encryption, caching, and performance monitoring.
"""

import imaplib
import email
import smtplib
import ssl
import hashlib
import json
import logging
import os
import sys
import threading
import queue
import time
import re
import base64
from typing import Dict, List, Tuple, Optional, Any, Union, Generator
from dataclasses import dataclass, field, asdict
from datetime import datetime, timedelta, timezone
from collections import defaultdict, OrderedDict, Counter
from email.header import decode_header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from email.utils import parseaddr, formataddr, parsedate_to_datetime
from functools import lru_cache, wraps
from contextlib import contextmanager
import pickle
import uuid
import html
import mimetypes
from urllib.parse import urlparse

try:
    from cassandra.cluster import Cluster, ExecutionProfile
    from cassandra.auth import PlainTextAuthProvider
    from cassandra.policies import DCAwareRoundRobinPolicy, TokenAwarePolicy, RetryPolicy
    from cassandra.query import SimpleStatement, BatchStatement, ConsistencyLevel
    from cassandra import ReadTimeout, WriteTimeout, Unavailable
    from cassandra.concurrent import execute_concurrent_with_args
except ImportError:
    print("Cassandra driver required. Install with: pip install cassandra-driver")
    sys.exit(1)

try:
    from cryptography.fernet import Fernet
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2
except ImportError:
    print("Cryptography required for message encryption. Install with: pip install cryptography")
    sys.exit(1)

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(name)s | %(levelname)s | %(message)s',
    handlers=[
        logging.FileHandler('communication_platform.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


@dataclass
class EmailMessage:
    """Structured representation of an email message with full metadata."""
    
    message_id: str
    subject: str
    sender: str
    recipients: List[str]
    cc: List[str] = field(default_factory=list)
    bcc: List[str] = field(default_factory=list)
    date: datetime = field(default_factory=datetime.now)
    body_text: str = ""
    body_html: str = ""
    attachments: List[Dict[str, Any]] = field(default_factory=list)
    headers: Dict[str, str] = field(default_factory=dict)
    folder: str = "INBOX"
    flags: List[str] = field(default_factory=list)
    thread_id: Optional[str] = None
    priority: int = 3  # 1=highest, 5=lowest
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for storage."""
        return {
            'message_id': self.message_id,
            'subject': self.subject,
            'sender': self.sender,
            'recipients': json.dumps(self.recipients),
            'date': self.date,
            'body_text': self.body_text,
            'folder': self.folder,
            'thread_id': self.thread_id,
            'priority': self.priority
        }


@dataclass
class ChatMessage:
    """Structured chat message with enhanced metadata."""
    
    message_id: uuid.UUID
    sender_id: uuid.UUID
    message_text: str
    message_time: datetime
    message_type: str = "text"  # text, file, image, code, system
    edited: bool = False
    edit_time: Optional[datetime] = None
    reactions: Dict[str, List[uuid.UUID]] = field(default_factory=dict)
    thread_id: Optional[uuid.UUID] = None
    mentions: List[uuid.UUID] = field(default_factory=list)
    attachments: List[str] = field(default_factory=list)
    read_by: List[uuid.UUID] = field(default_factory=list)
    encrypted: bool = False
    
    def encrypt_content(self, key: bytes) -> str:
        """Encrypt message content using Fernet symmetric encryption."""
        f = Fernet(key)
        encrypted = f.encrypt(self.message_text.encode())
        self.encrypted = True
        return base64.b64encode(encrypted).decode()
    
    def decrypt_content(self, key: bytes, encrypted_text: str) -> str:
        """Decrypt message content."""
        f = Fernet(key)
        encrypted = base64.b64decode(encrypted_text.encode())
        decrypted = f.decrypt(encrypted)
        return decrypted.decode()


class CassandraManager:
    """Advanced Cassandra connection and query management with caching and monitoring."""
    
    def __init__(self, hosts: List[str] = None, keyspace: str = 'employee_chat_db',
                 replication_factor: int = 3, enable_caching: bool = True):
        """
        Initialize Cassandra connection with advanced configuration.
        
        Args:
            hosts: List of Cassandra node IPs
            keyspace: Target keyspace name
            replication_factor: Data replication factor
            enable_caching: Enable query result caching
        """
        self.hosts = hosts or ['127.0.0.1']
        self.keyspace = keyspace
        self.replication_factor = replication_factor
        self.enable_caching = enable_caching
        self.cluster = None
        self.session = None
        self.prepared_statements = {}
        self.query_cache = OrderedDict() if enable_caching else None
        self.cache_size = 1000
        self.metrics = defaultdict(int)
        
        self._connect()
        self._create_schema()
        self._prepare_statements()
    
    def _connect(self):
        """Establish cluster connection with optimized settings."""
        
        # Create execution profiles for different consistency needs
        profiles = {
            ExecutionProfile(
                load_balancing_policy=TokenAwarePolicy(DCAwareRoundRobinPolicy()),
                consistency_level=ConsistencyLevel.LOCAL_QUORUM,
                request_timeout=10.0,
                retry_policy=RetryPolicy()
            )
        }
        
        try:
            self.cluster = Cluster(
                self.hosts,
                execution_profiles={'default': profiles[0]},
                protocol_version=4,
                compression=True
            )
            self.session = self.cluster.connect()
            logger.info(f"Connected to Cassandra cluster at {self.hosts}")
        except Exception as e:
            logger.error(f"Failed to connect to Cassandra: {e}")
            raise
    
    def _create_schema(self):
        """Create keyspace and tables with proper data modeling."""
        
        # Create keyspace with NetworkTopologyStrategy for production
        self.session.execute(f"""
            CREATE KEYSPACE IF NOT EXISTS {self.keyspace}
            WITH replication = {{'class': 'SimpleStrategy', 
                                'replication_factor': {self.replication_factor}}}
        """)
        
        self.session.set_keyspace(self.keyspace)
        logger.info(f"Using keyspace: {self.keyspace}")
        
        # Team chat table with message threading support
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS team_chats (
                team_id UUID,
                bucket int,
                message_time timestamp,
                message_id UUID,
                sender_id UUID,
                message_text text,
                message_type text,
                thread_id UUID,
                mentions set<UUID>,
                attachments list<text>,
                reactions map<text, frozen<set<UUID>>>,
                edited boolean,
                edit_time timestamp,
                encrypted boolean,
                PRIMARY KEY ((team_id, bucket), message_time, message_id)
            ) WITH CLUSTERING ORDER BY (message_time DESC)
            AND compaction = {'class': 'TimeWindowCompactionStrategy',
                            'compaction_window_unit': 'DAYS',
                            'compaction_window_size': 1}
            AND gc_grace_seconds = 86400
            AND default_time_to_live = 7776000
        """)
        
        # Direct messages with encryption support
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS employee_chats (
                user_pair text,
                bucket int,
                message_time timestamp,
                message_id UUID,
                sender_id UUID,
                message_text text,
                message_type text,
                thread_id UUID,
                attachments list<text>,
                read_status map<UUID, boolean>,
                encrypted boolean,
                deleted_for set<UUID>,
                PRIMARY KEY ((user_pair, bucket), message_time, message_id)
            ) WITH CLUSTERING ORDER BY (message_time DESC)
            AND default_time_to_live = 2592000
        """)
        
        # User presence and status tracking
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS user_presence (
                user_id UUID PRIMARY KEY,
                status text,
                status_message text,
                last_seen timestamp,
                active_teams set<UUID>,
                notification_preferences map<text, text>,
                public_key text
            )
        """)
        
        # Message search index using materialized view
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS message_search_index (
                search_term text,
                message_time timestamp,
                message_id UUID,
                team_id UUID,
                sender_id UUID,
                message_preview text,
                PRIMARY KEY (search_term, message_time, message_id)
            ) WITH CLUSTERING ORDER BY (message_time DESC)
        """)
        
        # Email integration table
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS email_messages (
                user_id UUID,
                folder text,
                message_time timestamp,
                message_id text,
                subject text,
                sender text,
                recipients text,
                body_text text,
                thread_id text,
                priority int,
                read boolean,
                flagged boolean,
                attachments list<text>,
                PRIMARY KEY ((user_id, folder), message_time, message_id)
            ) WITH CLUSTERING ORDER BY (message_time DESC)
        """)
        
        # Analytics and metrics table
        self.session.execute("""
            CREATE TABLE IF NOT EXISTS communication_metrics (
                metric_date date,
                metric_hour int,
                metric_type text,
                team_id UUID,
                user_id UUID,
                count counter,
                PRIMARY KEY ((metric_date, metric_hour), metric_type, team_id, user_id)
            )
        """)
        
        logger.info("Schema creation completed")
    
    def _prepare_statements(self):
        """Prepare frequently used statements for performance."""
        
        # Team chat insertion
        self.prepared_statements['insert_team_chat'] = self.session.prepare("""
            INSERT INTO team_chats (
                team_id, bucket, message_time, message_id, sender_id,
                message_text, message_type, thread_id, mentions,
                attachments, reactions, edited, edit_time, encrypted
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """)
        
        # Employee chat insertion
        self.prepared_statements['insert_employee_chat'] = self.session.prepare("""
            INSERT INTO employee_chats (
                user_pair, bucket, message_time, message_id, sender_id,
                message_text, message_type, thread_id, attachments,
                read_status, encrypted, deleted_for
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """)
        
        # Team message retrieval
        self.prepared_statements['get_team_messages'] = self.session.prepare("""
            SELECT * FROM team_chats 
            WHERE team_id = ? AND bucket = ?
            ORDER BY message_time DESC
            LIMIT ?
        """)
        
        # Search index update
        self.prepared_statements['update_search_index'] = self.session.prepare("""
            INSERT INTO message_search_index (
                search_term, message_time, message_id,
                team_id, sender_id, message_preview
            ) VALUES (?, ?, ?, ?, ?, ?)
        """)
        
        logger.info("Prepared statements ready")
    
    @contextmanager
    def batch_context(self):
        """Context manager for batch operations."""
        batch = BatchStatement()
        try:
            yield batch
            self.session.execute(batch)
            self.metrics['batch_operations'] += 1
        except Exception as e:
            logger.error(f"Batch execution failed: {e}")
            raise
    
    def _get_bucket(self, timestamp: datetime, bucket_size_hours: int = 6) -> int:
        """Calculate time bucket for even data distribution."""
        epoch = datetime(1970, 1, 1, tzinfo=timezone.utc)
        hours_since_epoch = (timestamp - epoch).total_seconds() / 3600
        return int(hours_since_epoch // bucket_size_hours)
    
    def insert_team_message(self, team_id: uuid.UUID, message: ChatMessage) -> bool:
        """
        Insert team chat message with automatic indexing.
        
        Args:
            team_id: Team identifier
            message: ChatMessage object
            
        Returns:
            Success status
        """
        try:
            bucket = self._get_bucket(message.message_time)
            
            # Encrypt if needed
            message_text = message.message_text
            if message.encrypted:
                # In production, retrieve key from secure storage
                key = self._get_encryption_key(team_id)
                message_text = message.encrypt_content(key)
            
            # Insert main message
            self.session.execute(
                self.prepared_statements['insert_team_chat'],
                (
                    team_id, bucket, message.message_time, message.message_id,
                    message.sender_id, message_text, message.message_type,
                    message.thread_id, set(message.mentions), message.attachments,
                    message.reactions, message.edited, message.edit_time,
                    message.encrypted
                )
            )
            
            # Update search index
            self._update_search_index(message, team_id)
            
            # Update metrics
            self._update_metrics('team_message', team_id, message.sender_id)
            
            self.metrics['messages_inserted'] += 1
            logger.debug(f"Inserted team message {message.message_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to insert team message: {e}")
            self.metrics['insert_failures'] += 1
            return False
    
    def insert_employee_message(self, user1: uuid.UUID, user2: uuid.UUID,
                               message: ChatMessage) -> bool:
        """
        Insert direct message between employees.
        
        Args:
            user1: First user ID
            user2: Second user ID
            message: ChatMessage object
            
        Returns:
            Success status
        """
        try:
            # Create consistent user pair key
            user_pair = self._create_user_pair(user1, user2)
            bucket = self._get_bucket(message.message_time)
            
            # Initialize read status
            read_status = {user1: True if message.sender_id == user1 else False,
                         user2: True if message.sender_id == user2 else False}
            
            self.session.execute(
                self.prepared_statements['insert_employee_chat'],
                (
                    user_pair, bucket, message.message_time, message.message_id,
                    message.sender_id, message.message_text, message.message_type,
                    message.thread_id, message.attachments, read_status,
                    message.encrypted, set()
                )
            )
            
            self.metrics['dm_inserted'] += 1
            return True
            
        except Exception as e:
            logger.error(f"Failed to insert employee message: {e}")
            return False
    
    def get_team_messages(self, team_id: uuid.UUID, hours_back: int = 24,
                         limit: int = 100) -> List[Dict]:
        """
        Retrieve recent team messages with caching.
        
        Args:
            team_id: Team identifier
            hours_back: Hours to look back
            limit: Maximum messages to return
            
        Returns:
            List of message dictionaries
        """
        cache_key = f"team_{team_id}_{hours_back}_{limit}"
        
        # Check cache first
        if self.enable_caching and cache_key in self.query_cache:
            self.metrics['cache_hits'] += 1
            return self.query_cache[cache_key]
        
        messages = []
        current_time = datetime.now(timezone.utc)
        
        # Query multiple buckets if needed
        for hours_ago in range(0, hours_back, 6):
            query_time = current_time - timedelta(hours=hours_ago)
            bucket = self._get_bucket(query_time)
            
            rows = self.session.execute(
                self.prepared_statements['get_team_messages'],
                (team_id, bucket, limit)
            )
            
            for row in rows:
                message_dict = {
                    'message_id': row.message_id,
                    'sender_id': row.sender_id,
                    'message_time': row.message_time,
                    'message_text': row.message_text,
                    'message_type': row.message_type,
                    'thread_id': row.thread_id,
                    'mentions': list(row.mentions) if row.mentions else [],
                    'attachments': row.attachments or [],
                    'reactions': dict(row.reactions) if row.reactions else {},
                    'edited': row.edited,
                    'encrypted': row.encrypted
                }
                
                # Decrypt if needed
                if row.encrypted:
                    key = self._get_encryption_key(team_id)
                    decryptor = ChatMessage(
                        message_id=row.message_id,
                        sender_id=row.sender_id,
                        message_text="",
                        message_time=row.message_time
                    )
                    message_dict['message_text'] = decryptor.decrypt_content(
                        key, row.message_text
                    )
                
                messages.append(message_dict)
                
                if len(messages) >= limit:
                    break
            
            if len(messages) >= limit:
                break
        
        # Update cache
        if self.enable_caching:
            self._update_cache(cache_key, messages)
        
        self.metrics['queries_executed'] += 1
        return messages[:limit]
    
    def get_employee_messages(self, user1: uuid.UUID, user2: uuid.UUID,
                            limit: int = 50) -> List[Dict]:
        """
        Retrieve direct messages between two employees.
        
        Args:
            user1: First user ID
            user2: Second user ID
            limit: Maximum messages to return
            
        Returns:
            List of message dictionaries
        """
        user_pair = self._create_user_pair(user1, user2)
        bucket = self._get_bucket(datetime.now(timezone.utc))
        
        query = """
            SELECT * FROM employee_chats
            WHERE user_pair = %s AND bucket = %s
            ORDER BY message_time DESC
            LIMIT %s
        """
        
        rows = self.session.execute(query, (user_pair, bucket, limit))
        
        messages = []
        for row in rows:
            # Check if message is deleted for either user
            if user1 in (row.deleted_for or set()) or user2 in (row.deleted_for or set()):
                continue
            
            messages.append({
                'message_id': row.message_id,
                'sender_id': row.sender_id,
                'message_time': row.message_time,
                'message_text': row.message_text,
                'message_type': row.message_type,
                'thread_id': row.thread_id,
                'attachments': row.attachments or [],
                'read_status': dict(row.read_status) if row.read_status else {},
                'encrypted': row.encrypted
            })
        
        return messages
    
    def search_messages(self, search_terms: List[str], team_id: Optional[uuid.UUID] = None,
                       limit: int = 50) -> List[Dict]:
        """
        Search messages using the search index.
        
        Args:
            search_terms: List of terms to search
            team_id: Optional team filter
            limit: Maximum results
            
        Returns:
            List of matching messages
        """
        results = []
        
        for term in search_terms:
            term_lower = term.lower()
            
            query = """
                SELECT * FROM message_search_index
                WHERE search_term = %s
                LIMIT %s
            """
            
            rows = self.session.execute(query, (term_lower, limit))
            
            for row in rows:
                if team_id and row.team_id != team_id:
                    continue
                
                results.append({
                    'message_id': row.message_id,
                    'team_id': row.team_id,
                    'sender_id': row.sender_id,
                    'message_time': row.message_time,
                    'message_preview': row.message_preview,
                    'search_term': term
                })
        
        # Sort by relevance and time
        results.sort(key=lambda x: x['message_time'], reverse=True)
        return results[:limit]
    
    def update_user_presence(self, user_id: uuid.UUID, status: str,
                           status_message: str = "") -> bool:
        """
        Update user presence and status.
        
        Args:
            user_id: User identifier
            status: Status (online, away, busy, offline)
            status_message: Optional status message
            
        Returns:
            Success status
        """
        try:
            query = """
                UPDATE user_presence
                SET status = %s,
                    status_message = %s,
                    last_seen = %s
                WHERE user_id = %s
            """
            
            self.session.execute(
                query,
                (status, status_message, datetime.now(timezone.utc), user_id)
            )
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to update presence: {e}")
            return False
    
    def _create_user_pair(self, user1: uuid.UUID, user2: uuid.UUID) -> str:
        """Create consistent user pair identifier."""
        return f"{min(str(user1), str(user2))}:{max(str(user1), str(user2))}"
    
    def _get_encryption_key(self, identifier: uuid.UUID) -> bytes:
        """
        Get or generate encryption key for team/user.
        In production, this should retrieve from secure key management.
        """
        # This is a simplified example - use proper key management in production
        salt = str(identifier).encode()
        kdf = PBKDF2(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(b"master_password"))
        return key
    
    def _update_search_index(self, message: ChatMessage, team_id: uuid.UUID):
        """Update search index with message terms."""
        # Extract searchable terms (simplified - use proper NLP in production)
        terms = set()
        words = message.message_text.lower().split()
        
        for word in words:
            # Clean and filter words
            word = re.sub(r'[^\w\s]', '', word)
            if len(word) > 2:  # Skip very short words
                terms.add(word)
        
        # Index each term
        preview = message.message_text[:100]
        with self.batch_context() as batch:
            for term in terms:
                batch.add(
                    self.prepared_statements['update_search_index'],
                    (term, message.message_time, message.message_id,
                     team_id, message.sender_id, preview)
                )
    
    def _update_metrics(self, metric_type: str, team_id: uuid.UUID, user_id: uuid.UUID):
        """Update communication metrics."""
        now = datetime.now(timezone.utc)
        
        query = """
            UPDATE communication_metrics
            SET count = count + 1
            WHERE metric_date = %s
                AND metric_hour = %s
                AND metric_type = %s
                AND team_id = %s
                AND user_id = %s
        """
        
        self.session.execute(
            query,
            (now.date(), now.hour, metric_type, team_id, user_id)
        )
    
    def _update_cache(self, key: str, value: Any):
        """Update LRU cache with size limit."""
        if not self.enable_caching:
            return
        
        # Remove oldest if cache is full
        if len(self.query_cache) >= self.cache_size:
            self.query_cache.popitem(last=False)
        
        self.query_cache[key] = value
    
    def get_metrics(self) -> Dict[str, int]:
        """Return performance metrics."""
        return dict(self.metrics)
    
    def close(self):
        """Close Cassandra connections."""
        if self.session:
            self.session.shutdown()
        if self.cluster:
            self.cluster.shutdown()
        logger.info("Cassandra connections closed")


class EmailManager:
    """Advanced email management with threading, filtering, and attachment handling."""
    
    def __init__(self, email_user: str, email_pass: str,
                 imap_server: str = "imap.gmail.com",
                 smtp_server: str = "smtp.gmail.com",
                 imap_port: int = 993, smtp_port: int = 587):
        """
        Initialize email manager with IMAP and SMTP configuration.
        
        Args:
            email_user: Email address
            email_pass: Email password or app-specific password
            imap_server: IMAP server hostname
            smtp_server: SMTP server hostname
            imap_port: IMAP port (993 for SSL)
            smtp_port: SMTP port (587 for TLS)
        """
        self.email_user = email_user
        self.email_pass = email_pass
        self.imap_server = imap_server
        self.smtp_server = smtp_server
        self.imap_port = imap_port
        self.smtp_port = smtp_port
        self.imap_connection = None
        self.smtp_connection = None
        self.folder_cache = {}
        self.thread_cache = {}
        
    def connect_imap(self) -> bool:
        """Establish IMAP connection for reading emails."""
        try:
            self.imap_connection = imaplib.IMAP4_SSL(self.imap_server, self.imap_port)
            self.imap_connection.login(self.email_user, self.email_pass)
            logger.info(f"Connected to IMAP server {self.imap_server}")
            
            # Cache folder list
            self._cache_folders()
            return True
            
        except imaplib.IMAP4.error as e:
            logger.error(f"IMAP authentication failed: {e}")
            return False
        except Exception as e:
            logger.error(f"IMAP connection failed: {e}")
            return False
    
    def connect_smtp(self) -> bool:
        """Establish SMTP connection for sending emails."""
        try:
            self.smtp_connection = smtplib.SMTP(self.smtp_server, self.smtp_port)
            self.smtp_connection.starttls()
            self.smtp_connection.login(self.email_user, self.email_pass)
            logger.info(f"Connected to SMTP server {self.smtp_server}")
            return True
            
        except smtplib.SMTPException as e:
            logger.error(f"SMTP connection failed: {e}")
            return False
    
    def _cache_folders(self):
        """Cache available email folders."""
        if not self.imap_connection:
            return
        
        status, folders = self.imap_connection.list()
        if status == 'OK':
            for folder_info in folders:
                # Parse folder info
                if isinstance(folder_info, bytes):
                    folder_info = folder_info.decode('utf-8')
                
                # Extract folder name
                match = re.search(r'"([^"]+)"$', folder_info)
                if match:
                    folder_name = match.group(1)
                    self.folder_cache[folder_name] = True
        
        logger.debug(f"Cached {len(self.folder_cache)} folders")
    
    def fetch_emails(self, folder: str = "INBOX", limit: int = 10,
                     since_date: Optional[datetime] = None,
                     search_criteria: str = "ALL") -> List[EmailMessage]:
        """
        Fetch emails with advanced filtering and parsing.
        
        Args:
            folder: Email folder to search
            limit: Maximum emails to retrieve
            since_date: Only fetch emails since this date
            search_criteria: IMAP search criteria
            
        Returns:
            List of EmailMessage objects
        """
        if not self.imap_connection:
            logger.error("No IMAP connection established")
            return []
        
        messages = []
        
        try:
            # Select folder
            self.imap_connection.select(folder)
            
            # Build search criteria
            if since_date:
                date_str = since_date.strftime("%d-%b-%Y")
                search_criteria = f'(SINCE {date_str})'
            
            # Search messages
            status, data = self.imap_connection.search(None, search_criteria)
            if status != 'OK':
                logger.error(f"Search failed: {status}")
                return []
            
            email_ids = data[0].split()
            
            # Limit results
            if limit > 0:
                email_ids = email_ids[-limit:]
            
            # Fetch each email
            for email_id in email_ids:
                try:
                    email_msg = self._fetch_single_email(email_id, folder)
                    if email_msg:
                        messages.append(email_msg)
                        
                except Exception as e:
                    logger.error(f"Failed to fetch email {email_id}: {e}")
                    continue
            
            logger.info(f"Fetched {len(messages)} emails from {folder}")
            
        except Exception as e:
            logger.error(f"Failed to fetch emails: {e}")
        
        return messages
    
    def _fetch_single_email(self, email_id: bytes, folder: str) -> Optional[EmailMessage]:
        """
        Fetch and parse a single email.
        
        Args:
            email_id: Email identifier
            folder: Current folder
            
        Returns:
            EmailMessage object or None
        """
        # Fetch email data
        status, data = self.imap_connection.fetch(email_id, '(RFC822 FLAGS)')
        if status != 'OK':
            return None
        
        # Parse email
        raw_email = data[0][1]
        msg = email.message_from_bytes(raw_email)
        
        # Extract headers
        subject = self._decode_header(msg.get('Subject', ''))
        sender = self._parse_address(msg.get('From', ''))
        recipients = self._parse_addresses(msg.get('To', ''))
        cc = self._parse_addresses(msg.get('Cc', ''))
        message_id = msg.get('Message-ID', str(uuid.uuid4()))
        
        # Parse date
        date_str = msg.get('Date', '')
        try:
            date = parsedate_to_datetime(date_str)
        except:
            date = datetime.now(timezone.utc)
        
        # Extract body and attachments
        body_text, body_html, attachments = self._extract_body_and_attachments(msg)
        
        # Get flags
        flags = []
        if len(data) > 1 and isinstance(data[1], bytes):
            flags_match = re.search(rb'FLAGS \(([^)]*)\)', data[1])
            if flags_match:
                flags = flags_match.group(1).decode().split()
        
        # Detect thread
        thread_id = self._detect_thread(msg)
        
        # Determine priority
        priority = self._determine_priority(msg)
        
        return EmailMessage(
            message_id=message_id,
            subject=subject,
            sender=sender,
            recipients=recipients,
            cc=cc,
            date=date,
            body_text=body_text,
            body_html=body_html,
            attachments=attachments,
            folder=folder,
            flags=flags,
            thread_id=thread_id,
            priority=priority
        )
    
    def _decode_header(self, header_value: str) -> str:
        """Decode email header with proper encoding handling."""
        if not header_value:
            return ""
        
        decoded_parts = []
        for part, encoding in decode_header(header_value):
            if isinstance(part, bytes):
                try:
                    if encoding:
                        decoded_parts.append(part.decode(encoding))
                    else:
                        decoded_parts.append(part.decode('utf-8', errors='ignore'))
                except:
                    decoded_parts.append(part.decode('utf-8', errors='ignore'))
            else:
                decoded_parts.append(part)
        
        return ' '.join(decoded_parts)
    
    def _parse_address(self, address_str: str) -> str:
        """Parse email address from header."""
        if not address_str:
            return ""
        
        name, addr = parseaddr(address_str)
        if addr:
            return addr
        return address_str
    
    def _parse_addresses(self, addresses_str: str) -> List[str]:
        """Parse multiple email addresses."""
        if not addresses_str:
            return []
        
        addresses = []
        for addr_part in addresses_str.split(','):
            addr = self._parse_address(addr_part.strip())
            if addr:
                addresses.append(addr)
        
        return addresses
    
    def _extract_body_and_attachments(self, msg) -> Tuple[str, str, List[Dict]]:
        """Extract email body and attachments."""
        body_text = ""
        body_html = ""
        attachments = []
        
        if msg.is_multipart():
            for part in msg.walk():
                content_type = part.get_content_type()
                content_disposition = part.get('Content-Disposition', '')
                
                # Skip container parts
                if part.is_multipart():
                    continue
                
                # Check for attachment
                if 'attachment' in content_disposition:
                    filename = part.get_filename()
                    if filename:
                        filename = self._decode_header(filename)
                        attachments.append({
                            'filename': filename,
                            'content_type': content_type,
                            'size': len(part.get_payload(decode=True))
                        })
                
                # Extract body
                elif content_type == 'text/plain' and not body_text:
                    payload = part.get_payload(decode=True)
                    if payload:
                        body_text = payload.decode('utf-8', errors='ignore')
                
                elif content_type == 'text/html' and not body_html:
                    payload = part.get_payload(decode=True)
                    if payload:
                        body_html = payload.decode('utf-8', errors='ignore')
        else:
            # Single part message
            payload = msg.get_payload(decode=True)
            if payload:
                if msg.get_content_type() == 'text/html':
                    body_html = payload.decode('utf-8', errors='ignore')
                else:
                    body_text = payload.decode('utf-8', errors='ignore')
        
        # If no text body, try to extract from HTML
        if not body_text and body_html:
            body_text = self._html_to_text(body_html)
        
        return body_text, body_html, attachments
    
    def _html_to_text(self, html_content: str) -> str:
        """Convert HTML to plain text (simplified)."""
        # Remove HTML tags
        text = re.sub(r'<[^>]+>', '', html_content)
        # Decode HTML entities
        text = html.unescape(text)
        # Clean up whitespace
        text = re.sub(r'\s+', ' ', text).strip()
        return text
    
    def _detect_thread(self, msg) -> Optional[str]:
        """Detect email thread using headers."""
        # Check for thread headers
        thread_headers = ['Thread-Topic', 'Thread-Index', 'In-Reply-To', 'References']
        
        for header in thread_headers:
            value = msg.get(header)
            if value:
                # Create thread ID from header
                thread_id = hashlib.md5(value.encode()).hexdigest()
                return thread_id
        
        return None
    
    def _determine_priority(self, msg) -> int:
        """Determine email priority from headers."""
        # Check X-Priority header
        x_priority = msg.get('X-Priority', '')
        if x_priority:
            try:
                return int(x_priority[0])
            except:
                pass
        
        # Check Importance header
        importance = msg.get('Importance', '').lower()
        if importance == 'high':
            return 1
        elif importance == 'low':
            return 5
        
        return 3  # Normal priority
    
    def send_email(self, to_addresses: List[str], subject: str,
                  body_text: str, body_html: Optional[str] = None,
                  cc_addresses: Optional[List[str]] = None,
                  bcc_addresses: Optional[List[str]] = None,
                  attachments: Optional[List[str]] = None,
                  priority: int = 3) -> bool:
        """
        Send email with full MIME support.
        
        Args:
            to_addresses: List of recipient addresses
            subject: Email subject
            body_text: Plain text body
            body_html: Optional HTML body
            cc_addresses: CC recipients
            bcc_addresses: BCC recipients
            attachments: List of file paths to attach
            priority: Email priority (1=high, 5=low)
            
        Returns:
            Success status
        """
        if not self.smtp_connection:
            if not self.connect_smtp():
                return False
        
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['From'] = self.email_user
            msg['To'] = ', '.join(to_addresses)
            msg['Subject'] = subject
            msg['Date'] = email.utils.formatdate(localtime=True)
            msg['Message-ID'] = email.utils.make_msgid()
            
            # Set priority
            msg['X-Priority'] = str(priority)
            if priority == 1:
                msg['Importance'] = 'High'
            elif priority == 5:
                msg['Importance'] = 'Low'
            
            # Add CC/BCC
            if cc_addresses:
                msg['Cc'] = ', '.join(cc_addresses)
            
            # Add body
            msg.attach(MIMEText(body_text, 'plain'))
            if body_html:
                msg.attach(MIMEText(body_html, 'html'))
            
            # Add attachments
            if attachments:
                for file_path in attachments:
                    if os.path.isfile(file_path):
                        self._attach_file(msg, file_path)
            
            # Prepare recipient list
            all_recipients = to_addresses.copy()
            if cc_addresses:
                all_recipients.extend(cc_addresses)
            if bcc_addresses:
                all_recipients.extend(bcc_addresses)
            
            # Send email
            self.smtp_connection.send_message(msg, self.email_user, all_recipients)
            
            logger.info(f"Email sent to {len(all_recipients)} recipients")
            return True
            
        except Exception as e:
            logger.error(f"Failed to send email: {e}")
            return False
    
    def _attach_file(self, msg: MIMEMultipart, file_path: str):
        """Attach file to email message."""
        filename = os.path.basename(file_path)
        
        # Guess content type
        ctype, encoding = mimetypes.guess_type(file_path)
        if ctype is None:
            ctype = 'application/octet-stream'
        
        maintype, subtype = ctype.split('/', 1)
        
        # Read file
        with open(file_path, 'rb') as f:
            file_data = f.read()
        
        # Create attachment
        attachment = MIMEBase(maintype, subtype)
        attachment.set_payload(file_data)
        encoders.encode_base64(attachment)
        attachment.add_header('Content-Disposition', f'attachment; filename="{filename}"')
        
        msg.attach(attachment)
    
    def create_folder(self, folder_name: str) -> bool:
        """Create new email folder."""
        if not self.imap_connection:
            return False
        
        try:
            status, data = self.imap_connection.create(folder_name)
            if status == 'OK':
                self.folder_cache[folder_name] = True
                logger.info(f"Created folder: {folder_name}")
                return True
            return False
            
        except Exception as e:
            logger.error(f"Failed to create folder: {e}")
            return False
    
    def move_email(self, email_id: bytes, source_folder: str, dest_folder: str) -> bool:
        """Move email between folders."""
        if not self.imap_connection:
            return False
        
        try:
            # Select source folder
            self.imap_connection.select(source_folder)
            
            # Copy to destination
            status, data = self.imap_connection.copy(email_id, dest_folder)
            if status != 'OK':
                return False
            
            # Mark for deletion in source
            self.imap_connection.store(email_id, '+FLAGS', '\\Deleted')
            
            # Expunge to complete deletion
            self.imap_connection.expunge()
            
            logger.debug(f"Moved email from {source_folder} to {dest_folder}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to move email: {e}")
            return False
    
    def mark_as_read(self, email_id: bytes, folder: str = "INBOX") -> bool:
        """Mark email as read."""
        return self._set_flag(email_id, folder, '\\Seen')
    
    def mark_as_unread(self, email_id: bytes, folder: str = "INBOX") -> bool:
        """Mark email as unread."""
        return self._remove_flag(email_id, folder, '\\Seen')
    
    def flag_email(self, email_id: bytes, folder: str = "INBOX") -> bool:
        """Flag email for follow-up."""
        return self._set_flag(email_id, folder, '\\Flagged')
    
    def _set_flag(self, email_id: bytes, folder: str, flag: str) -> bool:
        """Set flag on email."""
        if not self.imap_connection:
            return False
        
        try:
            self.imap_connection.select(folder)
            status, data = self.imap_connection.store(email_id, '+FLAGS', flag)
            return status == 'OK'
            
        except Exception as e:
            logger.error(f"Failed to set flag: {e}")
            return False
    
    def _remove_flag(self, email_id: bytes, folder: str, flag: str) -> bool:
        """Remove flag from email."""
        if not self.imap_connection:
            return False
        
        try:
            self.imap_connection.select(folder)
            status, data = self.imap_connection.store(email_id, '-FLAGS', flag)
            return status == 'OK'
            
        except Exception as e:
            logger.error(f"Failed to remove flag: {e}")
            return False
    
    def close(self):
        """Close email connections."""
        if self.imap_connection:
            try:
                self.imap_connection.logout()
            except:
                pass
        
        if self.smtp_connection:
            try:
                self.smtp_connection.quit()
            except:
                pass
        
        logger.info("Email connections closed")


class UnifiedCommunicationPlatform:
    """Main platform integrating chat and email systems."""
    
    def __init__(self, cassandra_hosts: List[str] = None,
                 email_config: Optional[Dict] = None):
        """
        Initialize unified communication platform.
        
        Args:
            cassandra_hosts: List of Cassandra node IPs
            email_config: Email configuration dictionary
        """
        # Initialize Cassandra
        self.cassandra = CassandraManager(hosts=cassandra_hosts)
        
        # Initialize Email if configured
        self.email = None
        if email_config:
            self.email = EmailManager(
                email_config['user'],
                email_config['password'],
                email_config.get('imap_server', 'imap.gmail.com'),
                email_config.get('smtp_server', 'smtp.gmail.com')
            )
            self.email.connect_imap()
        
        # Message queue for async processing
        self.message_queue = queue.Queue()
        self.processing_thread = None
        self.running = False
        
        logger.info("Unified Communication Platform initialized")
    
    def start_processing(self):
        """Start background message processing."""
        self.running = True
        self.processing_thread = threading.Thread(
            target=self._process_message_queue,
            daemon=True
        )
        self.processing_thread.start()
        logger.info("Background processing started")
    
    def stop_processing(self):
        """Stop background processing."""
        self.running = False
        if self.processing_thread:
            self.processing_thread.join(timeout=5)
        logger.info("Background processing stopped")
    
    def _process_message_queue(self):
        """Process queued messages asynchronously."""
        while self.running:
            try:
                # Get message from queue with timeout
                message_data = self.message_queue.get(timeout=1)
                
                # Process based on type
                if message_data['type'] == 'team_chat':
                    self.cassandra.insert_team_message(
                        message_data['team_id'],
                        message_data['message']
                    )
                elif message_data['type'] == 'employee_chat':
                    self.cassandra.insert_employee_message(
                        message_data['user1'],
                        message_data['user2'],
                        message_data['message']
                    )
                elif message_data['type'] == 'email':
                    self._store_email(message_data['email'])
                
                self.message_queue.task_done()
                
            except queue.Empty:
                continue
            except Exception as e:
                logger.error(f"Error processing message: {e}")
    
    def send_team_message(self, team_id: uuid.UUID, sender_id: uuid.UUID,
                         text: str, message_type: str = "text",
                         encrypt: bool = False) -> ChatMessage:
        """
        Send message to team chat.
        
        Args:
            team_id: Team identifier
            sender_id: Sender user ID
            text: Message text
            message_type: Type of message
            encrypt: Whether to encrypt message
            
        Returns:
            ChatMessage object
        """
        message = ChatMessage(
            message_id=uuid.uuid4(),
            sender_id=sender_id,
            message_text=text,
            message_time=datetime.now(timezone.utc),
            message_type=message_type,
            encrypted=encrypt
        )
        
        # Queue for async processing
        self.message_queue.put({
            'type': 'team_chat',
            'team_id': team_id,
            'message': message
        })
        
        logger.debug(f"Team message queued from {sender_id}")
        return message
    
    def send_direct_message(self, sender_id: uuid.UUID, recipient_id: uuid.UUID,
                          text: str, encrypt: bool = True) -> ChatMessage:
        """
        Send direct message to another user.
        
        Args:
            sender_id: Sender user ID
            recipient_id: Recipient user ID
            text: Message text
            encrypt: Whether to encrypt (default True for DMs)
            
        Returns:
            ChatMessage object
        """
        message = ChatMessage(
            message_id=uuid.uuid4(),
            sender_id=sender_id,
            message_text=text,
            message_time=datetime.now(timezone.utc),
            encrypted=encrypt
        )
        
        # Queue for async processing
        self.message_queue.put({
            'type': 'employee_chat',
            'user1': sender_id,
            'user2': recipient_id,
            'message': message
        })
        
        logger.debug(f"Direct message queued from {sender_id} to {recipient_id}")
        return message
    
    def sync_emails_to_cassandra(self, user_id: uuid.UUID, 
                                folder: str = "INBOX", 
                                limit: int = 100) -> int:
        """
        Sync emails to Cassandra for unified access.
        
        Args:
            user_id: User identifier
            folder: Email folder to sync
            limit: Maximum emails to sync
            
        Returns:
            Number of emails synced
        """
        if not self.email:
            logger.error("Email not configured")
            return 0
        
        # Fetch emails
        emails = self.email.fetch_emails(folder, limit)
        
        # Store in Cassandra
        synced = 0
        for email_msg in emails:
            if self._store_email_for_user(user_id, email_msg):
                synced += 1
        
        logger.info(f"Synced {synced} emails for user {user_id}")
        return synced
    
    def _store_email_for_user(self, user_id: uuid.UUID, 
                             email_msg: EmailMessage) -> bool:
        """Store email in Cassandra for user."""
        try:
            query = """
                INSERT INTO email_messages (
                    user_id, folder, message_time, message_id,
                    subject, sender, recipients, body_text,
                    thread_id, priority, read, flagged, attachments
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            
            self.cassandra.session.execute(
                query,
                (
                    user_id,
                    email_msg.folder,
                    email_msg.date,
                    email_msg.message_id,
                    email_msg.subject,
                    email_msg.sender,
                    json.dumps(email_msg.recipients),
                    email_msg.body_text[:10000],  # Limit text size
                    email_msg.thread_id,
                    email_msg.priority,
                    '\\Seen' in email_msg.flags,
                    '\\Flagged' in email_msg.flags,
                    [att['filename'] for att in email_msg.attachments]
                )
            )
            
            return True
            
        except Exception as e:
            logger.error(f"Failed to store email: {e}")
            return False
    
    def get_unified_inbox(self, user_id: uuid.UUID, limit: int = 50) -> List[Dict]:
        """
        Get unified view of chats and emails.
        
        Args:
            user_id: User identifier
            limit: Maximum items to return
            
        Returns:
            List of communication items
        """
        items = []
        
        # Get recent emails
        email_query = """
            SELECT * FROM email_messages
            WHERE user_id = ? AND folder = ?
            LIMIT ?
        """
        
        email_rows = self.cassandra.session.execute(
            email_query,
            (user_id, 'INBOX', limit // 2)
        )
        
        for row in email_rows:
            items.append({
                'type': 'email',
                'id': row.message_id,
                'time': row.message_time,
                'subject': row.subject,
                'sender': row.sender,
                'preview': row.body_text[:100],
                'priority': row.priority,
                'read': row.read
            })
        
        # Get recent chats (simplified - would need user's teams in production)
        # This is a placeholder for demonstration
        
        # Sort by time
        items.sort(key=lambda x: x['time'], reverse=True)
        
        return items[:limit]
    
    def search_all_communications(self, user_id: uuid.UUID, 
                                 query: str, 
                                 limit: int = 50) -> List[Dict]:
        """
        Search across all communication channels.
        
        Args:
            user_id: User identifier
            query: Search query
            limit: Maximum results
            
        Returns:
            List of search results
        """
        results = []
        search_terms = query.lower().split()
        
        # Search chat messages
        chat_results = self.cassandra.search_messages(search_terms, limit=limit)
        for result in chat_results:
            results.append({
                'type': 'chat',
                'source': 'team' if result.get('team_id') else 'direct',
                **result
            })
        
        # Search emails (simplified - would use full-text search in production)
        email_query = """
            SELECT * FROM email_messages
            WHERE user_id = ?
            LIMIT ?
            ALLOW FILTERING
        """
        
        email_rows = self.cassandra.session.execute(
            email_query,
            (user_id, limit)
        )
        
        for row in email_rows:
            # Simple text matching
            if any(term in row.subject.lower() or term in row.body_text.lower() 
                  for term in search_terms):
                results.append({
                    'type': 'email',
                    'message_id': row.message_id,
                    'time': row.message_time,
                    'subject': row.subject,
                    'sender': row.sender,
                    'preview': row.body_text[:100]
                })
        
        # Sort by relevance and time
        results.sort(key=lambda x: x.get('time', datetime.min), reverse=True)
        
        return results[:limit]
    
    def generate_analytics_report(self, team_id: Optional[uuid.UUID] = None,
                                 days_back: int = 7) -> Dict:
        """
        Generate communication analytics report.
        
        Args:
            team_id: Optional team filter
            days_back: Days to analyze
            
        Returns:
            Analytics dictionary
        """
        report = {
            'period': f"Last {days_back} days",
            'generated_at': datetime.now(timezone.utc).isoformat(),
            'metrics': {}
        }
        
        # Message volume metrics
        start_date = datetime.now(timezone.utc) - timedelta(days=days_back)
        
        # Query metrics table
        metrics_query = """
            SELECT metric_type, SUM(count) as total
            FROM communication_metrics
            WHERE metric_date >= ?
        """
        
        if team_id:
            metrics_query += " AND team_id = ?"
            params = (start_date.date(), team_id)
        else:
            params = (start_date.date(),)
        
        metrics_query += " GROUP BY metric_type"
        
        try:
            rows = self.cassandra.session.execute(metrics_query, params)
            
            for row in rows:
                report['metrics'][row.metric_type] = row.total
                
        except Exception as e:
            logger.error(f"Failed to generate analytics: {e}")
        
        # Add Cassandra performance metrics
        report['system_metrics'] = self.cassandra.get_metrics()
        
        return report
    
    def close(self):
        """Shutdown platform and close connections."""
        self.stop_processing()
        self.cassandra.close()
        if self.email:
            self.email.close()
        logger.info("Platform shutdown complete")


def main():
    """Demonstration of the unified communication platform."""
    
    # Configuration
    cassandra_hosts = ['127.0.0.1']
    
    # Email configuration (optional)
    email_config = None  # Set your email credentials here if needed
    # email_config = {
    #     'user': 'your_email@example.com',
    #     'password': 'your_app_password'
    # }
    
    # Initialize platform
    platform = UnifiedCommunicationPlatform(
        cassandra_hosts=cassandra_hosts,
        email_config=email_config
    )
    
    # Start background processing
    platform.start_processing()
    
    try:
        # Create sample users and team
        team_id = uuid.uuid4()
        user1_id = uuid.uuid4()
        user2_id = uuid.uuid4()
        
        logger.info(f"Created team {team_id}")
        logger.info(f"Created users {user1_id} and {user2_id}")
        
        # Send team messages
        platform.send_team_message(
            team_id, user1_id,
            "Team meeting scheduled for 2 PM today",
            message_type="text"
        )
        
        platform.send_team_message(
            team_id, user2_id,
            "I've updated the project documentation",
            message_type="text"
        )
        
        # Send direct message
        platform.send_direct_message(
            user1_id, user2_id,
            "Can you review my latest code changes?",
            encrypt=True
        )
        
        # Wait for async processing
        time.sleep(2)
        
        # Retrieve messages
        logger.info("\n" + "="*60)
        logger.info("RETRIEVING TEAM MESSAGES")
        logger.info("="*60)
        
        team_messages = platform.cassandra.get_team_messages(team_id, limit=10)
        for msg in team_messages:
            logger.info(f"{msg['message_time']} | {msg['sender_id']}: {msg['message_text']}")
        
        logger.info("\n" + "="*60)
        logger.info("RETRIEVING DIRECT MESSAGES")
        logger.info("="*60)
        
        dm_messages = platform.cassandra.get_employee_messages(user1_id, user2_id)
        for msg in dm_messages:
            logger.info(f"{msg['message_time']} | {msg['sender_id']}: {msg['message_text']}")
        
        # Update user presence
        platform.cassandra.update_user_presence(
            user1_id, "online", "Working on project X"
        )
        
        # Generate analytics
        logger.info("\n" + "="*60)
        logger.info("ANALYTICS REPORT")
        logger.info("="*60)
        
        report = platform.generate_analytics_report(team_id)
        logger.info(f"Report: {json.dumps(report, indent=2, default=str)}")
        
        # Demonstrate email integration if configured
        if platform.email:
            logger.info("\n" + "="*60)
            logger.info("EMAIL INTEGRATION")
            logger.info("="*60)
            
            # Fetch recent emails
            emails = platform.email.fetch_emails(limit=5)
            for email_msg in emails:
                logger.info(f"Email: {email_msg.subject} from {email_msg.sender}")
            
            # Sync to Cassandra
            synced = platform.sync_emails_to_cassandra(user1_id, limit=10)
            logger.info(f"Synced {synced} emails to Cassandra")
        
    except Exception as e:
        logger.error(f"Error in demonstration: {e}")
    
    finally:
        # Cleanup
        platform.close()
        logger.info("Demonstration complete")


if __name__ == "__main__":
    main()
