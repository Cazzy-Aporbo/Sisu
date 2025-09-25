"""
ASCII-Binary-Art Mini-Language

Features:
- Convert text to binary
- Convert binary to text
- Visualize binary as ASCII art
- Encode/decode messages with XOR
- Play with ASCII-binary patterns
"""

def text_to_binary(text):
    """Convert a string to a list of 8-bit binary strings."""
    return [format(ord(c), '08b') for c in text]

def binary_to_text(bin_list):
    """Convert a list of 8-bit binary strings back to text."""
    return ''.join([chr(int(b, 2)) for b in bin_list])

def visualize_binary(bin_list, one='#', zero=' '):
    """Visualize binary strings as ASCII art."""
    for b in bin_list:
        print(b.replace('0', zero).replace('1', one))

def encode_message(text, key=0b10101010):
    """Encode text by XORing each char's ASCII with key."""
    return [format(ord(c) ^ key, '08b') for c in text]

def decode_message(bin_list, key=0b10101010):
    """Decode a list of binary strings XORed with key."""
    return ''.join([chr(int(b, 2) ^ key) for b in bin_list])

def main():
    print("ASCII-Binary-Art Mini-Language")
    print("Commands: text, binary, visualize, encode, decode, exit")
    
    while True:
        cmd = input("\n> ").strip().lower()
        
        if cmd == "exit":
            print("Goodbye")
            break
        
        elif cmd == "text":
            t = input("Enter text: ")
            b = text_to_binary(t)
            print("Binary:", b)
        
        elif cmd == "binary":
            b = input("Enter binary (space separated 8-bit values): ").split()
            t = binary_to_text(b)
            print("Text:", t)
        
        elif cmd == "visualize":
            t = input("Enter text to visualize: ")
            b = text_to_binary(t)
            visualize_binary(b)
        
        elif cmd == "encode":
            t = input("Enter text to encode: ")
            k = input("Optional key in binary (press Enter for default): ")
            key = int(k,2) if k else 0b10101010
            b = encode_message(t, key)
            print("Encoded binary:", b)
        
        elif cmd == "decode":
            b = input("Enter binary to decode (space separated): ").split()
            k = input("Optional key in binary (press Enter for default): ")
            key = int(k,2) if k else 0b10101010
            t = decode_message(b, key)
            print("Decoded text:", t)
        
        else:
            print("Unknown command. Try: text, binary, visualize, encode, decode, exit")

if __name__ == "__main__":
    main()