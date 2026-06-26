"""
Punk Records ↔ Hermes Bridge (File-based)
Translates Punk Records markdown messages to Hermes format.
"""

import json
import sys
import time
from pathlib import Path
from datetime import datetime

# Add punk-records to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / "punk-records"))
from punk_records import get_messages, send_message, load_state, PUNK_RECORDS_DIR

class PunkHermesBridge:
    """Bridge between Punk Records (file-based) and Hermes (HTTP)."""
    
    def __init__(self, satellite_name="edison-dev"):
        self.satellite = satellite_name
        self.state = load_state()
        self.last_check = datetime.now()
        
    def check_punk_messages(self):
        """Check for new Punk Records messages."""
        messages = get_messages(self.satellite, since=self.last_check)
        self.last_check = datetime.now()
        return messages
    
    def format_for_hermes(self, msg):
        """Convert Punk Records message to Hermes format."""
        return {
            "role": "user",
            "content": f"[Punk Records from {msg['from']}] {msg['body']}",
            "metadata": {
                "source": "punk_records",
                "msg_id": msg["id"],
                "sender": msg["from"],
                "tags": msg.get("tags", [])
            }
        }
    
    def send_to_punk(self, recipient, body, msg_type="status"):
        """Send a message via Punk Records."""
        return send_message(
            from_satellite=self.satellite,
            to=[recipient],
            msg_type=msg_type,
            body=body
        )
    
    def status(self):
        """Show bridge status."""
        punk_dir = PUNK_RECORDS_DIR.exists()
        inbox_exists = (PUNK_RECORDS_DIR / "inbox").exists()
        outbox_exists = (PUNK_RECORDS_DIR / "outbox").exists()
        
        return {
            "satellite": self.satellite,
            "punk_records_dir": str(PUNK_RECORDS_DIR),
            "punk_dir_exists": punk_dir,
            "inbox_exists": inbox_exists,
            "outbox_exists": outbox_exists,
            "last_check": self.last_check.isoformat(),
        }

def main():
    print("=" * 60)
    print("Punk Records <-> Hermes Bridge (File-based)")
    print("=" * 60)
    
    bridge = PunkHermesBridge("edison-dev")
    
    # Show status
    status = bridge.status()
    print(f"\nSatellite: {status['satellite']}")
    print(f"Punk Records dir: {status['punk_records_dir']}")
    print(f"Inbox exists: {'YES' if status['inbox_exists'] else 'NO'}")
    print(f"Outbox exists: {'YES' if status['outbox_exists'] else 'NO'}")
    
    # Check for messages
    print("\n[*] Checking Punk Records messages...")
    messages = bridge.check_punk_messages()
    
    if messages:
        print(f"[+] Found {len(messages)} message(s):")
        for msg in messages:
            print(f"  - From: {msg['from']}")
            print(f"    Type: {msg['type']}")
            print(f"    Body: {msg['body'][:80]}...")
    else:
        print("[*] No new messages")
    
    # Test send
    print("\n[*] Testing Punk Records send...")
    result = bridge.send_to_punk("ohm", "Edison-dev bridge test message", "status")
    print(f"[+] Sent test message to ohm")
    
    print("\n[+] Bridge test complete")
    print("[+] Ready for integration with Hermes")

if __name__ == "__main__":
    main()
