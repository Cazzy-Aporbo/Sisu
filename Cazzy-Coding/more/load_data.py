#!/usr/bin/env python3
"""
Cassandra Chat Message System 
High-performance data generation and management for distributed chat systems
using Apache Cassandra with advanced consistency and partitioning strategies.
Author: Cazandra Aporbo; Updated November 2025
"""

import os
import sys
import uuid
import random
import json
import hashlib
import logging
import argparse
import signal
import threading
import time
from typing import Dict, List, Optional, Tuple, Any, Generator
from dataclasses import dataclass, field, asdict
from datetime import datetime, timedelta, timezone
from collections import defaultdict, Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
from enum import Enum
import pickle
import zlib

try:
    from cassandra.cluster import Cluster, ExecutionProfile, EXEC_PROFILE_DEFAULT
    from cassandra.policies import DCAwareRoundRobinPolicy, RetryPolicy, TokenAwarePolicy
    from cassandra.auth import PlainTextAuthProvider
    from cassandra.query import BatchStatement, BatchType, ConsistencyLevel, SimpleStatement
    from cassandra.concurrent import execute_concurrent_with_args
    from cassandra import OperationTimedOut, Unavailable, ReadTimeout, WriteTimeout
    from cassandra.pool import Host
except ImportError:
    print("Cassandra driver not installed. Run: pip install cassandra-driver")
    sys.exit(1)

try:
    from faker import Faker
    from faker.providers import internet, company, person
except ImportError:
    print("Faker not installed. Run: pip install faker")
    sys.exit(1)


logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class MessageType(Enum):
    """Enumeration of message types for categorization."""
    TEXT = "text"
    CODE = "code"
    IMAGE = "image"
    FILE = "file"
    SYSTEM = "system"
    THREAD_REPLY = "thread_reply"
    REACTION = "reaction"
    EDIT = "edit"
    DELETE = "delete"


class ChannelType(Enum):
    """Channel categorization for realistic workplace communication."""
    GENERAL = "general"
    RANDOM = "random"
    DEVELOPMENT = "dev"
    SUPPORT = "support"
    INCIDENTS = "incidents"
    ANNOUNCEMENTS = "announcements"
    STANDUP = "standup"
    DESIGN = "design"
    PRODUCT = "product"
    SALES = "sales"
    PRIVATE = "private"
    ARCHIVED = "archived"


@dataclass
class UserProfile:
    """Represents a user with realistic attributes."""
    user_id: str
    email: str
    display_name: str
    department: str
    role: str
    timezone: str
    active_hours: Tuple[int, int]
    message_frequency: float
    expertise_areas: List[str] = field(default_factory=list)
    language_style: str = "professional"
    join_date: datetime = field(default_factory=datetime.now)
    
    def to_dict(self) -> Dict:
        """Convert to Cassandra-compatible dictionary."""
        return {
            'sender_id': self.user_id,
            'sender_email': self.email,
            'display_name': self.display_name,
            'department': self.department,
            'role': self.role
        }


@dataclass
class MessageContent:
    """Sophisticated message content generation."""
    text: str
    message_type: MessageType
    thread_id: Optional[str] = None
    attachments: List[Dict] = field(default_factory=list)
    mentions: List[str] = field(default_factory=list)
    code_blocks: List[Dict] = field(default_factory=list)
    links: List[str] = field(default_factory=list)
    
    def serialize(self) -> str:
        """Serialize complex content for storage."""
        return json.dumps({
            'text': self.text,
            'type': self.message_type.value,
            'thread_id': self.thread_id,
            'attachments': self.attachments,
            'mentions': self.mentions,
            'code_blocks': self.code_blocks,
            'links': self.links
        })


class RealisticDataGenerator:
    """Generates contextually appropriate chat messages."""
    
    def __init__(self, seed: Optional[int] = None):
        self.fake = Faker()
        if seed:
            Faker.seed(seed)
            random.seed(seed)
        
        self.fake.add_provider(internet)
        self.fake.add_provider(company)
        self.fake.add_provider(person)
        
        self.tech_terms = [
            'deployment', 'pipeline', 'kubernetes', 'docker', 'API', 'endpoint',
            'database', 'cache', 'queue', 'microservice', 'lambda', 'function',
            'terraform', 'ansible', 'jenkins', 'CI/CD', 'monitoring', 'metrics'
        ]
        
        self.business_terms = [
            'quarterly', 'KPI', 'OKR', 'revenue', 'forecast', 'budget',
            'stakeholder', 'roadmap', 'milestone', 'deliverable', 'timeline'
        ]
        
        self.code_languages = ['python', 'javascript', 'go', 'rust', 'java', 'sql']
        
        self.departments = ['Engineering', 'Product', 'Sales', 'Support', 'Design', 'Marketing', 'Operations']
        self.roles = ['Engineer', 'Manager', 'Director', 'Analyst', 'Designer', 'VP', 'Specialist']
        
    def generate_user(self) -> UserProfile:
        """Create a realistic user profile."""
        department = random.choice(self.departments)
        role = random.choice(self.roles)
        
        # Activity patterns based on role
        if 'Engineer' in role:
            active_hours = (9, 19)
            message_freq = 0.7
            expertise = random.sample(self.tech_terms, 3)
        elif 'Manager' in role or 'Director' in role:
            active_hours = (8, 18)
            message_freq = 0.5
            expertise = random.sample(self.business_terms, 2)
        else:
            active_hours = (9, 17)
            message_freq = 0.4
            expertise = []
        
        return UserProfile(
            user_id=str(uuid.uuid4()),
            email=self.fake.company_email(),
            display_name=self.fake.name(),
            department=department,
            role=f"{role}, {department}",
            timezone=random.choice(['UTC', 'PST', 'EST', 'CST', 'GMT', 'CET']),
            active_hours=active_hours,
            message_frequency=message_freq,
            expertise_areas=expertise,
            language_style=random.choice(['professional', 'casual', 'technical']),
            join_date=self.fake.date_time_between(start_date='-2y', end_date='-1w')
        )
    
    def generate_contextual_message(self, channel: ChannelType, sender: UserProfile, 
                                   context: Dict = None) -> MessageContent:
        """Generate message appropriate for channel and sender."""
        
        message_type = self._select_message_type(channel)
        
        if message_type == MessageType.CODE:
            return self._generate_code_message(sender)
        elif message_type == MessageType.SYSTEM:
            return self._generate_system_message()
        elif channel == ChannelType.INCIDENTS:
            return self._generate_incident_message(sender)
        elif channel == ChannelType.STANDUP:
            return self._generate_standup_message(sender)
        elif channel in [ChannelType.DEVELOPMENT, ChannelType.DESIGN]:
            return self._generate_technical_message(sender, channel)
        else:
            return self._generate_general_message(sender, channel)
    
    def _select_message_type(self, channel: ChannelType) -> MessageType:
        """Select appropriate message type based on channel."""
        if channel == ChannelType.DEVELOPMENT:
            weights = [0.6, 0.3, 0.05, 0.05, 0.0, 0.0, 0.0, 0.0, 0.0]
        elif channel == ChannelType.INCIDENTS:
            weights = [0.7, 0.1, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, 0.0]
        else:
            weights = [0.8, 0.05, 0.05, 0.05, 0.05, 0.0, 0.0, 0.0, 0.0]
        
        return random.choices(list(MessageType), weights=weights)[0]
    
    def _generate_code_message(self, sender: UserProfile) -> MessageContent:
        """Generate a code snippet message."""
        language = random.choice(self.code_languages)
        
        code_snippets = {
            'python': [
                'def process_data(items):\n    return [x * 2 for x in items if x > 0]',
                'async def fetch_results():\n    async with session.get(url) as resp:\n        return await resp.json()',
                'class DataProcessor:\n    def __init__(self):\n        self.cache = {}'
            ],
            'sql': [
                'SELECT user_id, COUNT(*) FROM messages GROUP BY user_id HAVING COUNT(*) > 100',
                'UPDATE users SET last_active = NOW() WHERE user_id = ?',
                'CREATE INDEX idx_messages_timestamp ON messages(created_at DESC)'
            ],
            'javascript': [
                'const result = items.filter(x => x.active).map(x => x.value)',
                'async function fetchData() { return await api.get("/endpoint") }',
                'export default class Component extends React.Component { }'
            ]
        }
        
        snippet = random.choice(code_snippets.get(language, ['// code here']))
        
        return MessageContent(
            text=f"Here's the {language} implementation:",
            message_type=MessageType.CODE,
            code_blocks=[{'language': language, 'code': snippet}]
        )
    
    def _generate_system_message(self) -> MessageContent:
        """Generate system notification."""
        events = [
            "Deployment completed successfully",
            "Database backup completed",
            "New user joined the workspace",
            "Scheduled maintenance window starting",
            "Alert resolved: High CPU usage",
            "Integration test suite passed"
        ]
        
        return MessageContent(
            text=random.choice(events),
            message_type=MessageType.SYSTEM
        )
    
    def _generate_incident_message(self, sender: UserProfile) -> MessageContent:
        """Generate incident-related message."""
        severities = ['SEV1', 'SEV2', 'SEV3']
        components = ['API Gateway', 'Database', 'Cache Layer', 'Message Queue', 'Load Balancer']
        
        templates = [
            "Investigating {severity} issue with {component} - response times elevated",
            "{component} showing degraded performance, monitoring closely",
            "Update: {component} issue resolved, conducting RCA",
            "Incident {severity}: {component} experiencing intermittent failures"
        ]
        
        text = random.choice(templates).format(
            severity=random.choice(severities),
            component=random.choice(components)
        )
        
        return MessageContent(text=text, message_type=MessageType.TEXT)
    
    def _generate_standup_message(self, sender: UserProfile) -> MessageContent:
        """Generate standup update."""
        yesterday = [
            "Completed API endpoint refactoring",
            "Fixed critical bug in payment processing",
            "Reviewed 3 pull requests",
            "Updated documentation for new features"
        ]
        
        today = [
            "Working on database optimization",
            "Implementing new authentication flow",
            "Meeting with product team for requirements",
            "Code review and testing"
        ]
        
        blockers = [
            "None",
            "Waiting for design specs",
            "Need access to staging environment",
            "Clarification needed on requirements"
        ]
        
        text = f"Yesterday: {random.choice(yesterday)}\nToday: {random.choice(today)}\nBlockers: {random.choice(blockers)}"
        
        return MessageContent(text=text, message_type=MessageType.TEXT)
    
    def _generate_technical_message(self, sender: UserProfile, channel: ChannelType) -> MessageContent:
        """Generate technical discussion message."""
        topics = sender.expertise_areas if sender.expertise_areas else self.tech_terms
        
        templates = [
            "Has anyone experienced issues with {tech} in production?",
            "Just deployed the fix for {tech} - monitoring metrics now",
            "Proposal: migrate {tech} to improve performance",
            "Quick question about {tech} configuration",
            "Sharing article about {tech} best practices: {link}"
        ]
        
        text = random.choice(templates).format(
            tech=random.choice(topics),
            link=self.fake.url()
        )
        
        return MessageContent(
            text=text,
            message_type=MessageType.TEXT,
            links=[self.fake.url()] if '{link}' in text else []
        )
    
    def _generate_general_message(self, sender: UserProfile, channel: ChannelType) -> MessageContent:
        """Generate general conversation message."""
        if sender.language_style == 'casual':
            text = self.fake.sentence(nb_words=random.randint(5, 15))
        elif sender.language_style == 'technical':
            text = f"Working on {random.choice(self.tech_terms)} implementation"
        else:
            text = self.fake.sentence(nb_words=random.randint(8, 12))
        
        # Add mentions occasionally
        mentions = []
        if random.random() < 0.2:
            mentions = [f"user_{random.randint(1, 100)}" for _ in range(random.randint(1, 3))]
            text = f"@{mentions[0]} {text}"
        
        return MessageContent(
            text=text,
            message_type=MessageType.TEXT,
            mentions=mentions
        )


class CassandraConnectionPool:
    """Manages Cassandra connections with health monitoring."""
    
    def __init__(self, hosts: List[str], keyspace: str, 
                 username: Optional[str] = None, password: Optional[str] = None):
        self.hosts = hosts
        self.keyspace = keyspace
        self.cluster = None
        self.session = None
        self.prepared_statements = {}
        self.connection_metrics = defaultdict(int)
        self.lock = threading.Lock()
        
        self._initialize_connection(username, password)
    
    def _initialize_connection(self, username: Optional[str], password: Optional[str]):
        """Initialize Cassandra cluster connection with optimized settings."""
        
        auth_provider = None
        if username and password:
            auth_provider = PlainTextAuthProvider(username=username, password=password)
        
        # Configure execution profiles for different consistency requirements
        profiles = {
            'default': ExecutionProfile(
                load_balancing_policy=TokenAwarePolicy(DCAwareRoundRobinPolicy()),
                retry_policy=RetryPolicy(),
                consistency_level=ConsistencyLevel.LOCAL_QUORUM,
                request_timeout=10.0
            ),
            'fast_read': ExecutionProfile(
                consistency_level=ConsistencyLevel.ONE,
                request_timeout=5.0
            ),
            'strong_write': ExecutionProfile(
                consistency_level=ConsistencyLevel.EACH_QUORUM,
                request_timeout=15.0
            )
        }
        
        self.cluster = Cluster(
            self.hosts,
            auth_provider=auth_provider,
            execution_profiles=profiles,
            protocol_version=4,
            compression=True,
            metrics_enabled=True
        )
        
        self.session = self.cluster.connect()
        logger.info(f"Connected to Cassandra cluster: {self.hosts}")
        
        self.session.set_keyspace(self.keyspace)
        logger.info(f"Using keyspace: {self.keyspace}")
    
    def prepare_statement(self, name: str, query: str) -> None:
        """Prepare and cache CQL statement."""
        with self.lock:
            if name not in self.prepared_statements:
                self.prepared_statements[name] = self.session.prepare(query)
                logger.debug(f"Prepared statement '{name}'")
    
    def execute_with_retry(self, statement, params=None, max_retries: int = 3, 
                          profile: str = 'default') -> Any:
        """Execute statement with automatic retry logic."""
        
        retry_count = 0
        last_exception = None
        
        while retry_count < max_retries:
            try:
                if params:
                    result = self.session.execute(statement, params, execution_profile=profile)
                else:
                    result = self.session.execute(statement, execution_profile=profile)
                
                self.connection_metrics['successful_queries'] += 1
                return result
                
            except (OperationTimedOut, Unavailable, ReadTimeout, WriteTimeout) as e:
                retry_count += 1
                last_exception = e
                self.connection_metrics['retried_queries'] += 1
                
                if retry_count < max_retries:
                    wait_time = 2 ** retry_count
                    logger.warning(f"Query failed, retrying in {wait_time}s: {e}")
                    time.sleep(wait_time)
                
            except Exception as e:
                self.connection_metrics['failed_queries'] += 1
                logger.error(f"Query failed permanently: {e}")
                raise
        
        self.connection_metrics['failed_queries'] += 1
        raise last_exception
    
    def execute_batch(self, statements: List[Tuple], batch_type: BatchType = BatchType.LOGGED) -> None:
        """Execute multiple statements in a batch."""
        
        batch = BatchStatement(batch_type=batch_type)
        
        for stmt, params in statements:
            batch.add(stmt, params)
        
        self.execute_with_retry(batch)
        self.connection_metrics['batch_operations'] += 1
    
    def execute_concurrent(self, statement, parameters_list: List, concurrency: int = 100) -> List:
        """Execute concurrent queries for high throughput."""
        
        results = execute_concurrent_with_args(
            self.session,
            statement,
            parameters_list,
            concurrency=concurrency
        )
        
        self.connection_metrics['concurrent_operations'] += 1
        return results
    
    def get_metrics(self) -> Dict:
        """Return connection and query metrics."""
        cluster_metrics = self.cluster.metrics.stats()
        return {
            'connection_metrics': dict(self.connection_metrics),
            'cluster_metrics': cluster_metrics
        }
    
    def health_check(self) -> bool:
        """Perform cluster health check."""
        try:
            self.session.execute("SELECT now() FROM system.local")
            return True
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return False
    
    def close(self):
        """Gracefully close connections."""
        if self.session:
            self.session.shutdown()
        if self.cluster:
            self.cluster.shutdown()
        logger.info("Cassandra connections closed")


class MessageIngestionPipeline:
    """High-performance message ingestion with batching and monitoring."""
    
    def __init__(self, connection_pool: CassandraConnectionPool, 
                 batch_size: int = 100, flush_interval: float = 5.0):
        self.pool = connection_pool
        self.batch_size = batch_size
        self.flush_interval = flush_interval
        self.message_buffer = []
        self.buffer_lock = threading.Lock()
        self.metrics = defaultdict(int)
        self.running = False
        self.flush_thread = None
        
        self._prepare_statements()
    
    def _prepare_statements(self):
        """Prepare all required CQL statements."""
        
        # Main message insertion
        self.pool.prepare_statement(
            'insert_message',
            """
            INSERT INTO messages_by_team (
                team_id, day, message_id, created_at, sender, 
                channel, content, metadata, message_type, thread_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            USING TTL ?
            """
        )
        
        # User activity tracking
        self.pool.prepare_statement(
            'update_user_activity',
            """
            UPDATE user_activity 
            SET message_count = message_count + 1,
                last_active = ?,
                channels_active = channels_active + ?
            WHERE user_id = ? AND day = ?
            """
        )
        
        # Channel statistics
        self.pool.prepare_statement(
            'update_channel_stats',
            """
            UPDATE channel_statistics
            SET message_count = message_count + 1,
                unique_users = unique_users + ?,
                peak_hour = ?
            WHERE channel = ? AND day = ?
            """
        )
    
    def start(self):
        """Start the ingestion pipeline."""
        self.running = True
        self.flush_thread = threading.Thread(target=self._periodic_flush, daemon=True)
        self.flush_thread.start()
        logger.info("Message ingestion pipeline started")
    
    def stop(self):
        """Stop the pipeline and flush remaining messages."""
        self.running = False
        if self.flush_thread:
            self.flush_thread.join()
        self._flush_buffer()
        logger.info("Message ingestion pipeline stopped")
    
    def ingest_message(self, team_id: str, user: UserProfile, channel: ChannelType,
                      content: MessageContent, timestamp: Optional[datetime] = None,
                      ttl: int = 7776000):  # 90 days default TTL
        """Add message to ingestion buffer."""
        
        if not timestamp:
            timestamp = datetime.now(timezone.utc)
        
        day = timestamp.strftime('%Y-%m-%d')
        message_id = uuid.uuid4()
        
        # Create message record
        message_record = {
            'team_id': team_id,
            'day': day,
            'message_id': message_id,
            'created_at': timestamp,
            'sender': user.to_dict(),
            'channel': channel.value,
            'content': content.serialize(),
            'metadata': self._generate_metadata(content),
            'message_type': content.message_type.value,
            'thread_id': content.thread_id,
            'ttl': ttl
        }
        
        with self.buffer_lock:
            self.message_buffer.append(message_record)
            self.metrics['messages_buffered'] += 1
            
            if len(self.message_buffer) >= self.batch_size:
                self._flush_buffer()
    
    def _generate_metadata(self, content: MessageContent) -> List[Dict]:
        """Generate message metadata for analytics."""
        
        metadata = []
        
        # Sentiment analysis (simplified)
        if any(word in content.text.lower() for word in ['great', 'excellent', 'awesome']):
            metadata.append({'key': 'sentiment', 'value': 'positive'})
        elif any(word in content.text.lower() for word in ['issue', 'problem', 'error']):
            metadata.append({'key': 'sentiment', 'value': 'negative'})
        else:
            metadata.append({'key': 'sentiment', 'value': 'neutral'})
        
        # Message characteristics
        metadata.append({'key': 'word_count', 'value': str(len(content.text.split()))})
        metadata.append({'key': 'has_mentions', 'value': str(bool(content.mentions))})
        metadata.append({'key': 'has_links', 'value': str(bool(content.links))})
        metadata.append({'key': 'has_code', 'value': str(bool(content.code_blocks))})
        
        return metadata
    
    def _flush_buffer(self):
        """Flush message buffer to Cassandra."""
        
        with self.buffer_lock:
            if not self.message_buffer:
                return
            
            messages_to_flush = self.message_buffer.copy()
            self.message_buffer.clear()
        
        try:
            # Prepare batch statements
            batch_statements = []
            
            for msg in messages_to_flush:
                # Main message insert
                stmt = self.pool.prepared_statements['insert_message']
                params = (
                    msg['team_id'], msg['day'], msg['message_id'],
                    msg['created_at'], msg['sender'], msg['channel'],
                    msg['content'], msg['metadata'], msg['message_type'],
                    msg['thread_id'], msg['ttl']
                )
                batch_statements.append((stmt, params))
                
                # Update user activity
                if random.random() < 0.3:  # Sample for performance
                    activity_stmt = self.pool.prepared_statements['update_user_activity']
                    activity_params = (
                        msg['created_at'],
                        {msg['channel']},
                        msg['sender']['sender_id'],
                        msg['day']
                    )
                    batch_statements.append((activity_stmt, activity_params))
            
            # Execute in smaller chunks for reliability
            chunk_size = 25
            for i in range(0, len(batch_statements), chunk_size):
                chunk = batch_statements[i:i + chunk_size]
                self.pool.execute_batch(chunk)
            
            self.metrics['messages_flushed'] += len(messages_to_flush)
            self.metrics['flush_operations'] += 1
            
            logger.debug(f"Flushed {len(messages_to_flush)} messages to Cassandra")
            
        except Exception as e:
            logger.error(f"Failed to flush messages: {e}")
            self.metrics['flush_failures'] += 1
            
            # Re-add messages to buffer for retry
            with self.buffer_lock:
                self.message_buffer.extend(messages_to_flush)
    
    def _periodic_flush(self):
        """Periodically flush buffer even if not full."""
        
        while self.running:
            time.sleep(self.flush_interval)
            if self.message_buffer:
                logger.debug("Performing periodic flush")
                self._flush_buffer()
    
    def get_metrics(self) -> Dict:
        """Return ingestion metrics."""
        return dict(self.metrics)


class DataGenerator:
    """Orchestrates realistic data generation."""
    
    def __init__(self, connection_pool: CassandraConnectionPool):
        self.pool = connection_pool
        self.generator = RealisticDataGenerator()
        self.pipeline = MessageIngestionPipeline(connection_pool)
        
        # Generate stable user and team populations
        self.teams = [f"team_{i}" for i in range(1, 11)]
        self.users_by_team = self._generate_team_structures()
        self.channels_by_team = self._generate_channel_structures()
        
        self.message_threads = defaultdict(list)  # Track threads for replies
        
    def _generate_team_structures(self) -> Dict[str, List[UserProfile]]:
        """Generate realistic team structures."""
        
        teams = {}
        for team_id in self.teams:
            team_size = random.randint(10, 50)
            teams[team_id] = [
                self.generator.generate_user() 
                for _ in range(team_size)
            ]
            logger.info(f"Generated {team_size} users for {team_id}")
        
        return teams
    
    def _generate_channel_structures(self) -> Dict[str, List[ChannelType]]:
        """Generate channels per team."""
        
        base_channels = [
            ChannelType.GENERAL,
            ChannelType.RANDOM,
            ChannelType.ANNOUNCEMENTS
        ]
        
        channels = {}
        for team_id in self.teams:
            team_channels = base_channels.copy()
            
            # Add team-specific channels
            if 'engineering' in team_id.lower() or random.random() > 0.5:
                team_channels.extend([
                    ChannelType.DEVELOPMENT,
                    ChannelType.INCIDENTS,
                    ChannelType.STANDUP
                ])
            
            if random.random() > 0.3:
                team_channels.append(ChannelType.DESIGN)
            
            if random.random() > 0.5:
                team_channels.extend([ChannelType.PRODUCT, ChannelType.SALES])
            
            channels[team_id] = team_channels
            
        return channels
    
    def generate_historical_data(self, days: int = 30, messages_per_day: int = 1000):
        """Generate historical message data with realistic patterns."""
        
        self.pipeline.start()
        
        try:
            end_date = datetime.now(timezone.utc)
            start_date = end_date - timedelta(days=days)
            
            current_date = start_date
            total_messages = 0
            
            while current_date <= end_date:
                daily_messages = self._generate_daily_messages(
                    current_date, 
                    messages_per_day
                )
                total_messages += daily_messages
                
                logger.info(f"Generated {daily_messages} messages for {current_date.date()}")
                current_date += timedelta(days=1)
            
            logger.info(f"Total messages generated: {total_messages}")
            
        finally:
            self.pipeline.stop()
            metrics = self.pipeline.get_metrics()
            logger.info(f"Pipeline metrics: {metrics}")
    
    def _generate_daily_messages(self, date: datetime, target_count: int) -> int:
        """Generate messages for a specific day with realistic patterns."""
        
        messages_generated = 0
        
        # Distribute messages throughout the day with peaks
        hour_distribution = self._get_hourly_distribution(date.weekday())
        
        for hour, percentage in hour_distribution.items():
            hour_messages = int(target_count * percentage)
            
            for _ in range(hour_messages):
                team_id = random.choice(self.teams)
                user = self._select_active_user(team_id, hour)
                channel = random.choice(self.channels_by_team[team_id])
                
                # Generate timestamp within the hour
                minute = random.randint(0, 59)
                second = random.randint(0, 59)
                timestamp = date.replace(hour=hour, minute=minute, second=second)
                
                # Generate contextual message
                content = self.generator.generate_contextual_message(
                    channel, 
                    user,
                    {'threads': self.message_threads[team_id]}
                )
                
                # Thread handling
                if random.random() < 0.2 and self.message_threads[team_id]:
                    content.thread_id = random.choice(self.message_threads[team_id])
                elif random.random() < 0.1:
                    thread_id = str(uuid.uuid4())
                    self.message_threads[team_id].append(thread_id)
                    content.thread_id = thread_id
                
                self.pipeline.ingest_message(
                    team_id,
                    user,
                    channel,
                    content,
                    timestamp
                )
                
                messages_generated += 1
        
        return messages_generated
    
    def _get_hourly_distribution(self, weekday: int) -> Dict[int, float]:
        """Get realistic hourly message distribution."""
        
        if weekday in [5, 6]:  # Weekend
            distribution = {
                9: 0.02, 10: 0.03, 11: 0.03, 12: 0.02,
                13: 0.02, 14: 0.03, 15: 0.02, 16: 0.01
            }
        else:  # Weekday
            distribution = {
                8: 0.03, 9: 0.08, 10: 0.10, 11: 0.09,
                12: 0.06, 13: 0.07, 14: 0.09, 15: 0.10,
                16: 0.08, 17: 0.05, 18: 0.03, 19: 0.02
            }
        
        # Fill missing hours with minimal activity
        for hour in range(24):
            if hour not in distribution:
                distribution[hour] = 0.005
        
        # Normalize to ensure sum is 1.0
        total = sum(distribution.values())
        return {k: v/total for k, v in distribution.items()}
    
    def _select_active_user(self, team_id: str, hour: int) -> UserProfile:
        """Select user likely to be active at given hour."""
        
        team_users = self.users_by_team[team_id]
        
        # Filter users by active hours
        active_users = [
            u for u in team_users 
            if u.active_hours[0] <= hour <= u.active_hours[1]
        ]
        
        if not active_users:
            active_users = team_users
        
        # Weight by message frequency
        weights = [u.message_frequency for u in active_users]
        return random.choices(active_users, weights=weights)[0]
    
    def generate_realtime_stream(self, duration_seconds: int = 60, 
                                messages_per_second: float = 1.0):
        """Generate real-time message stream."""
        
        self.pipeline.start()
        start_time = time.time()
        messages_generated = 0
        
        try:
            while time.time() - start_time < duration_seconds:
                # Generate message
                team_id = random.choice(self.teams)
                user = random.choice(self.users_by_team[team_id])
                channel = random.choice(self.channels_by_team[team_id])
                content = self.generator.generate_contextual_message(channel, user)
                
                self.pipeline.ingest_message(team_id, user, channel, content)
                messages_generated += 1
                
                # Control rate
                sleep_time = 1.0 / messages_per_second
                time.sleep(sleep_time * random.uniform(0.5, 1.5))
            
            logger.info(f"Generated {messages_generated} real-time messages")
            
        finally:
            self.pipeline.stop()


def load_schema(session, schema_file: str = "schema.cql"):
    """Load and execute CQL schema."""
    
    if not os.path.exists(schema_file):
        logger.warning(f"Schema file not found: {schema_file}, using default schema")
        schema = """
        CREATE KEYSPACE IF NOT EXISTS chat_demo
        WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3};
        
        USE chat_demo;
        
        CREATE TABLE IF NOT EXISTS messages_by_team (
            team_id text,
            day text,
            message_id uuid,
            created_at timestamp,
            sender map<text, text>,
            channel text,
            content text,
            metadata list<frozen<map<text, text>>>,
            message_type text,
            thread_id text,
            PRIMARY KEY ((team_id, day), created_at, message_id)
        ) WITH CLUSTERING ORDER BY (created_at DESC);
        
        CREATE TABLE IF NOT EXISTS user_activity (
            user_id text,
            day text,
            message_count counter,
            last_active timestamp,
            channels_active set<text>,
            PRIMARY KEY ((user_id, day))
        );
        
        CREATE TABLE IF NOT EXISTS channel_statistics (
            channel text,
            day text,
            message_count counter,
            unique_users set<text>,
            peak_hour int,
            PRIMARY KEY ((channel, day))
        );
        
        CREATE INDEX IF NOT EXISTS idx_message_type 
        ON messages_by_team (message_type);
        
        CREATE INDEX IF NOT EXISTS idx_thread 
        ON messages_by_team (thread_id);
        """
    else:
        with open(schema_file, 'r') as f:
            schema = f.read()
    
    for statement in schema.split(';'):
        if statement.strip():
            try:
                session.execute(statement)
                logger.debug(f"Executed: {statement[:50]}...")
            except Exception as e:
                logger.error(f"Failed to execute statement: {e}")


def main():
    """Main execution entry point."""
    
    parser = argparse.ArgumentParser(description='Cassandra Chat Data Generator')
    parser.add_argument('--hosts', nargs='+', default=['127.0.0.1'],
                       help='Cassandra host addresses')
    parser.add_argument('--keyspace', default='chat_demo',
                       help='Cassandra keyspace')
    parser.add_argument('--username', help='Cassandra username')
    parser.add_argument('--password', help='Cassandra password')
    parser.add_argument('--mode', choices=['historical', 'realtime', 'both'],
                       default='historical', help='Generation mode')
    parser.add_argument('--days', type=int, default=7,
                       help='Days of historical data')
    parser.add_argument('--messages-per-day', type=int, default=1000,
                       help='Messages per day for historical mode')
    parser.add_argument('--duration', type=int, default=60,
                       help='Duration in seconds for realtime mode')
    parser.add_argument('--rate', type=float, default=1.0,
                       help='Messages per second for realtime mode')
    parser.add_argument('--schema-file', default='schema.cql',
                       help='Path to CQL schema file')
    parser.add_argument('--verbose', action='store_true',
                       help='Enable verbose logging')
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Initialize connection
    connection_pool = CassandraConnectionPool(
        args.hosts,
        args.keyspace,
        args.username,
        args.password
    )
    
    # Load schema
    load_schema(connection_pool.session, args.schema_file)
    
    # Initialize data generator
    generator = DataGenerator(connection_pool)
    
    try:
        if args.mode in ['historical', 'both']:
            logger.info("Starting historical data generation")
            generator.generate_historical_data(
                days=args.days,
                messages_per_day=args.messages_per_day
            )
        
        if args.mode in ['realtime', 'both']:
            logger.info("Starting real-time data generation")
            generator.generate_realtime_stream(
                duration_seconds=args.duration,
                messages_per_second=args.rate
            )
        
        # Print final metrics
        pool_metrics = connection_pool.get_metrics()
        logger.info(f"Final metrics: {pool_metrics}")
        
    except KeyboardInterrupt:
        logger.info("Generation interrupted by user")
    except Exception as e:
        logger.error(f"Generation failed: {e}")
        raise
    finally:
        connection_pool.close()


if __name__ == "__main__":
    main()
