"""
Agent Bridge -- File-Based Message Translation
Translates markdown message files to Hermes format.
"""

import json
import sys
import time
from pathlib import Path
from datetime import datetime

# Add message system to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent / "agent-messages"))

# Import from message system if available, otherwise define minimal version
try:
    from punk_records import get_messages, send_message, load_state
    MESSAGE_DIR = Path(__file__).parent.parent / "agent-messages"
except ImportError:
    MESSAGE_DIR = Path(__file__).parent.parent / "agent-messages"
    
    def load_state():
        return {}
    
    def get_messages(agent_name, since=None):
        return []
    
    def send_message(from_agent, to, msg_type, body, priority="normal", tags=None):
        msg_id = f"{from_agent}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        outbox = MESSAGE_DIR / "outbox"
        outbox.mkdir(parents=True, exist_ok=True)
        
        msg_file = outbox / f"{msg_id}.md"
        content = f"""---
id: "{msg_id}"
from: "{from_agent}"
to: {json.dumps(to)}
type: "{msg_type}"
priority: "{priority}"
tags: {json.dumps(tags or [])}
---

{body}
"""
        msg_file.write_text(content, encoding='utf-8')
        return {"status": "sent", "file": str(msg_file)}


class AgentBridge:
    """Bridge between file-based messages and Hermes (HTTP)."""
    
    def __init__(self, agent_name="edison"):
        self.agent = agent_name
        self.state = load_state()
        self.last_check = datetime.now()
        
    def check_messages(self):
        """Check for new messages."""
        messages = get_messages(self.agent, since=self.last_check)
        self.last_check = datetime.now()
        return messages
    
    def format_for_hermes(self, msg):
        """Convert message to Hermes format."""
        return {
            "role": "user",
            "content": f"[Message from {msg['from']}] {msg['body']}",
            "metadata": {
                "source": "file_sync",
                "msg_id": msg["id"],
                "sender": msg["from"],
                "tags": msg.get("tags", [])
            }
        }
    
    def send_message(self, recipient, body, msg_type="status"):
        """Send a message via file sync."""
        return send_message(
            from_agent=self.agent,
            to=[recipient],
            msg_type=msg_type,
            body=body
        )
    
    def status(self):
        """Show bridge status."""
        msg_dir = MESSAGE_DIR.exists()
        inbox_exists = (MESSAGE_DIR / "inbox").exists()
        outbox_exists = (MESSAGE_DIR / "outbox").exists()
        
        return {
            "agent": self.agent,
            "message_dir": str(MESSAGE_DIR),
            "dir_exists": msg_dir,
            "inbox_exists": inbox_exists,
            "outbox_exists": outbox_exists,
            "last_check": self.last_check.isoformat(),
        }

def main():
    print("=" * 60)
    print("Agent Message Bridge (File-based)")
    print("=" * 60)
    
    bridge = AgentBridge("edison")
    
    # Show status
    status = bridge.status()
    print(f"\nAgent: {status['agent']}")
    print(f"Message dir: {status['message_dir']}")
    print(f"Inbox exists: {'YES' if status['inbox_exists'] else 'NO'}")
    print(f"Outbox exists: {'YES' if status['outbox_exists'] else 'NO'}")
    
    # Check for messages
    print("\n[*] Checking messages...")
    messages = bridge.check_messages()
    
    if messages:
        print(f"[+] Found {len(messages)} message(s):")
        for msg in messages:
            print(f"  - From: {msg['from']}")
            print(f"    Type: {msg['type']}")
            print(f"    Body: {msg['body'][:80]}...")
    else:
        print("[*] No new messages")
    
    # Test send
    print("\n[*] Testing message send...")
    result = bridge.send_message("agent1", "Edison bridge test message", "status")
    print(f"[+] Sent test message to agent1")
    
    print("\n[+] Bridge test complete")
    print("[+] Ready for integration with Hermes")

if __name__ == "__main__":
    main()
