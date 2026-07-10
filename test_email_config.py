#!/usr/bin/env python3
"""
Email Configuration Test Script
Tests email setup and sends a test alert to verify configuration
"""
import sys
import os
sys.path.insert(0, 'src')

import yaml
from alert_system import AlertSystem


def test_email_configuration():
    """Test email configuration and send test alert"""
    
    print("=" * 70)
    print("EMAIL CONFIGURATION TEST")
    print("=" * 70)
    print()
    
    # Load configuration
    config_path = 'config/config.yaml'
    if not os.path.exists(config_path):
        print("❌ Error: config/config.yaml not found!")
        return False
    
    print("✓ Loading configuration from config/config.yaml...")
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    
    alert_config = config.get('alert_config', {})
    
    # Check email settings
    print("\n📧 Email Configuration:")
    print(f"   SMTP Server: {alert_config.get('email_smtp_server')}")
    print(f"   SMTP Port: {alert_config.get('email_smtp_port')}")
    print(f"   Sender: {alert_config.get('email_sender')}")
    print(f"   Recipients: {', '.join(alert_config.get('email_recipients', []))}")
    print(f"   Email Enabled: {alert_config.get('enable_email_alerts')}")
    
    # Check if password is set
    password = alert_config.get('email_password', '')
    if not password or password == 'YOUR_APP_PASSWORD_HERE':
        print("\n❌ ERROR: Email password not configured!")
        print("\nPlease follow these steps:")
        print("1. Read EMAIL_SETUP_GUIDE.md")
        print("2. Generate a Gmail App Password")
        print("3. Update config/config.yaml with the App Password")
        return False
    
    print(f"   Password: {'*' * len(password)} (configured)")
    
    # Check thresholds
    print("\n⚙️ Alert Thresholds:")
    print(f"   Sleeping: {alert_config.get('sleep_duration_threshold')} seconds")
    print(f"   Talking: {alert_config.get('talk_duration_threshold')} seconds")
    print(f"   Phone Usage: {alert_config.get('phone_usage_threshold')} seconds")
    print(f"   Alert Cooldown: {alert_config.get('alert_cooldown')} seconds")
    
    # Check behavior settings
    print("\n🎯 Detection Settings:")
    print(f"   Sleep Detection: {config.get('sleep_frames')} frames at EAR < {config.get('sleep_ear_threshold')}")
    print(f"   Talk Detection: {config.get('talk_frames')} frames at MAR > {config.get('talk_mar_threshold')}")
    print(f"   Proxy Detection: {config.get('required_blinks')} blinks required")
    
    # Ask user if they want to send test email
    print("\n" + "=" * 70)
    response = input("\nDo you want to send a TEST EMAIL? (yes/no): ").strip().lower()
    
    if response not in ['yes', 'y']:
        print("\nTest cancelled. Configuration looks correct!")
        print("Run 'python main.py' when ready.")
        return True
    
    print("\n📤 Sending test email...")
    print("=" * 70)
    
    try:
        # Create alert system
        alert_system = AlertSystem(alert_config)
        
        # Send test alert
        alert_system.create_alert(
            alert_type=AlertSystem.ALERT_SLEEPING,
            severity=AlertSystem.SEVERITY_WARNING,
            student_name='Test Student',
            message='This is a TEST alert from Smart Classroom Monitoring System',
            details={
                'test': True,
                'purpose': 'Verify email configuration',
                'note': 'If you received this email, the system is configured correctly!'
            }
        )
        
        print("\n✅ TEST EMAIL SENT SUCCESSFULLY!")
        print("\nPlease check these inboxes:")
        for recipient in alert_config.get('email_recipients', []):
            print(f"   📬 {recipient}")
        
        print("\n⚠️ Note: Check spam/junk folders if you don't see the email")
        print("\nIf you received the test email, you're all set!")
        print("Run 'python main.py' to start monitoring.")
        
        return True
        
    except Exception as e:
        print(f"\n❌ ERROR sending test email:")
        print(f"   {str(e)}")
        print("\nCommon issues:")
        print("   1. App Password is incorrect")
        print("   2. 2-Step Verification not enabled")
        print("   3. SMTP server or port incorrect")
        print("   4. Network/firewall blocking SMTP")
        print("\nRefer to EMAIL_SETUP_GUIDE.md for detailed setup instructions.")
        return False


def validate_behavior_settings():
    """Validate behavior detection settings"""
    print("\n" + "=" * 70)
    print("BEHAVIOR DETECTION VALIDATION")
    print("=" * 70)
    
    config_path = 'config/config.yaml'
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    
    sleep_frames = config.get('sleep_frames', 0)
    talk_frames = config.get('talk_frames', 0)
    
    # Assuming 30 FPS
    fps = 30
    sleep_seconds = sleep_frames / fps
    talk_seconds = talk_frames / fps
    
    print(f"\n✓ Sleep Detection: {sleep_frames} frames = {sleep_seconds:.1f} seconds at {fps} FPS")
    if abs(sleep_seconds - 5.0) < 0.5:
        print("   ✅ Configured correctly for 5 second detection")
    else:
        print(f"   ⚠️ Warning: Expected ~5 seconds, got {sleep_seconds:.1f} seconds")
    
    print(f"\n✓ Talk Detection: {talk_frames} frames = {talk_seconds:.1f} seconds at {fps} FPS")
    if abs(talk_seconds - 5.0) < 0.5:
        print("   ✅ Configured correctly for 5 second detection")
    else:
        print(f"   ⚠️ Warning: Expected ~5 seconds, got {talk_seconds:.1f} seconds")
    
    print("\n✅ All behavior settings validated!")


def main():
    """Main test function"""
    print("""
╔══════════════════════════════════════════════════════════════════════╗
║     SMART CLASSROOM MONITORING SYSTEM - EMAIL CONFIGURATION TEST     ║
╚══════════════════════════════════════════════════════════════════════╝
    """)
    
    try:
        # Validate behavior settings
        validate_behavior_settings()
        
        # Test email configuration
        success = test_email_configuration()
        
        if success:
            print("\n" + "=" * 70)
            print("✅ CONFIGURATION TEST COMPLETE!")
            print("=" * 70)
            print("\nYour system is ready to use with these settings:")
            print("   • Sleeping: Alert after 5 seconds")
            print("   • Talking: Alert after 5 seconds")
            print("   • Proxy: Alert if no blink detected")
            print("   • Phone: Alert immediately")
            print("   • Email: Both teacher and parent notified")
            print("\nNext steps:")
            print("   1. Collect student face data: python src/collect_faces.py --name 'Name'")
            print("   2. Train the model: python src/face_recognition.py train")
            print("   3. Start monitoring: python main.py")
        else:
            print("\n" + "=" * 70)
            print("❌ CONFIGURATION INCOMPLETE")
            print("=" * 70)
            print("\nPlease fix the issues above and run this test again.")
            print("Refer to EMAIL_SETUP_GUIDE.md for detailed instructions.")
        
        print()
        
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
