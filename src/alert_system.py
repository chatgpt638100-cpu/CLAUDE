"""
Alert System Module
Rule-based alert system for real-time teacher-parent notifications
Monitors behavior patterns and triggers alerts based on configurable rules
"""
import json
import os
from datetime import datetime, timedelta
from collections import defaultdict
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


class AlertSystem:
    """Rule-based alert system for classroom monitoring"""
    
    # Alert severity levels
    SEVERITY_INFO = "INFO"
    SEVERITY_WARNING = "WARNING"
    SEVERITY_CRITICAL = "CRITICAL"
    
    # Alert types
    ALERT_ABSENT = "ABSENT"
    ALERT_SLEEPING = "SLEEPING"
    ALERT_TALKING = "EXCESSIVE_TALKING"
    ALERT_PHONE_USAGE = "PHONE_USAGE"
    ALERT_PROXY_DETECTED = "PROXY_ATTENDANCE"
    ALERT_MULTIPLE_VIOLATIONS = "MULTIPLE_VIOLATIONS"
    
    def __init__(self, config=None):
        """
        Initialize Alert System
        
        Args:
            config: Configuration dictionary with alert rules and thresholds
        """
        # Default configuration
        self.config = {
            # Thresholds (in seconds)
            'sleep_duration_threshold': 60,      # Alert if sleeping > 1 minute
            'talk_duration_threshold': 120,      # Alert if talking > 2 minutes
            'phone_usage_threshold': 30,         # Alert if phone detected > 30 seconds
            
            # Count thresholds
            'max_violations_per_session': 3,     # Alert if > 3 violations
            
            # Alert cooldown (seconds) - prevent spam
            'alert_cooldown': 300,               # 5 minutes between same alerts
            
            # Notification methods
            'enable_console_alerts': True,
            'enable_file_alerts': True,
            'enable_email_alerts': False,        # Requires email configuration
            'enable_sound_alerts': False,
            
            # Email configuration (if enabled)
            'email_smtp_server': 'smtp.gmail.com',
            'email_smtp_port': 587,
            'email_sender': '',
            'email_password': '',
            'email_recipients': []
        }
        
        # Override with provided config
        if config:
            self.config.update(config)
        
        # Alert tracking
        self.active_alerts = {}
        self.alert_history = []
        self.student_violations = defaultdict(list)
        self.last_alert_time = defaultdict(lambda: datetime.min)
        
        # Alert statistics
        self.stats = {
            'total_alerts': 0,
            'alerts_by_type': defaultdict(int),
            'alerts_by_severity': defaultdict(int),
            'alerts_by_student': defaultdict(int)
        }
    
    def check_attendance_alert(self, all_students, present_students):
        """
        Check for absent students
        
        Args:
            all_students: List of all registered students
            present_students: List of students marked present
            
        Returns:
            List of alerts
        """
        alerts = []
        absent_students = [s for s in all_students if s not in present_students]
        
        for student in absent_students:
            alert = self.create_alert(
                alert_type=self.ALERT_ABSENT,
                severity=self.SEVERITY_WARNING,
                student_name=student,
                message=f"{student} is absent from class",
                details={'status': 'absent'}
            )
            alerts.append(alert)
        
        return alerts
    
    def check_sleeping_alert(self, behavior_results):
        """
        Check for sleeping students
        
        Args:
            behavior_results: List of behavior analysis results
            
        Returns:
            List of alerts
        """
        alerts = []
        
        for result in behavior_results:
            if result['is_sleeping'] and result.get('sleep_duration'):
                duration = result['sleep_duration']
                student_name = result.get('student_name', 'Unknown')
                
                # Check if duration exceeds threshold
                if duration > self.config['sleep_duration_threshold']:
                    # Check cooldown
                    if self._check_cooldown(student_name, self.ALERT_SLEEPING):
                        alert = self.create_alert(
                            alert_type=self.ALERT_SLEEPING,
                            severity=self.SEVERITY_WARNING,
                            student_name=student_name,
                            message=f"{student_name} has been sleeping for {int(duration)} seconds",
                            details={
                                'duration': duration,
                                'ear': result.get('ear', 0)
                            }
                        )
                        alerts.append(alert)
                        self._update_last_alert_time(student_name, self.ALERT_SLEEPING)
        
        return alerts
    
    def check_talking_alert(self, behavior_results):
        """
        Check for excessive talking
        
        Args:
            behavior_results: List of behavior analysis results
            
        Returns:
            List of alerts
        """
        alerts = []
        
        for result in behavior_results:
            if result['is_talking'] and result.get('talk_duration'):
                duration = result['talk_duration']
                student_name = result.get('student_name', 'Unknown')
                
                # Check if duration exceeds threshold
                if duration > self.config['talk_duration_threshold']:
                    # Check cooldown
                    if self._check_cooldown(student_name, self.ALERT_TALKING):
                        alert = self.create_alert(
                            alert_type=self.ALERT_TALKING,
                            severity=self.SEVERITY_INFO,
                            student_name=student_name,
                            message=f"{student_name} has been talking for {int(duration)} seconds",
                            details={
                                'duration': duration,
                                'mar': result.get('mar', 0)
                            }
                        )
                        alerts.append(alert)
                        self._update_last_alert_time(student_name, self.ALERT_TALKING)
        
        return alerts
    
    def check_phone_usage_alert(self, phone_incidents):
        """
        Check for mobile phone usage
        
        Args:
            phone_incidents: List of phone usage incidents
            
        Returns:
            List of alerts
        """
        alerts = []
        
        for incident in phone_incidents:
            student_name = incident.get('student_name', 'Unknown')
            
            if student_name != 'Unknown':
                # Check cooldown
                if self._check_cooldown(student_name, self.ALERT_PHONE_USAGE):
                    alert = self.create_alert(
                        alert_type=self.ALERT_PHONE_USAGE,
                        severity=self.SEVERITY_CRITICAL,
                        student_name=student_name,
                        message=f"{student_name} detected using mobile phone",
                        details={
                            'confidence': incident.get('phone_confidence', 0),
                            'distance': incident.get('distance', 0)
                        }
                    )
                    alerts.append(alert)
                    self._update_last_alert_time(student_name, self.ALERT_PHONE_USAGE)
        
        return alerts
    
    def check_proxy_attendance_alert(self, student_name, verification_result):
        """
        Check for proxy attendance attempts
        
        Args:
            student_name: Name of student
            verification_result: Anti-proxy verification result
            
        Returns:
            Alert if proxy detected
        """
        if not verification_result.get('is_live', True):
            alert = self.create_alert(
                alert_type=self.ALERT_PROXY_DETECTED,
                severity=self.SEVERITY_CRITICAL,
                student_name=student_name,
                message=f"Possible proxy attendance detected for {student_name}",
                details={
                    'verification_status': verification_result.get('status', 'Failed'),
                    'blinks': verification_result.get('blinks', 0)
                }
            )
            return alert
        return None
    
    def check_multiple_violations(self, student_name):
        """
        Check if student has multiple violations
        
        Args:
            student_name: Name of student
            
        Returns:
            Alert if threshold exceeded
        """
        violations = self.student_violations[student_name]
        
        # Count recent violations (within current session)
        recent_violations = [
            v for v in violations 
            if v['timestamp'] > datetime.now() - timedelta(hours=2)
        ]
        
        if len(recent_violations) >= self.config['max_violations_per_session']:
            if self._check_cooldown(student_name, self.ALERT_MULTIPLE_VIOLATIONS):
                alert = self.create_alert(
                    alert_type=self.ALERT_MULTIPLE_VIOLATIONS,
                    severity=self.SEVERITY_CRITICAL,
                    student_name=student_name,
                    message=f"{student_name} has {len(recent_violations)} violations",
                    details={
                        'violation_count': len(recent_violations),
                        'violations': [v['type'] for v in recent_violations]
                    }
                )
                self._update_last_alert_time(student_name, self.ALERT_MULTIPLE_VIOLATIONS)
                return alert
        
        return None
    
    def create_alert(self, alert_type, severity, student_name, message, details=None):
        """
        Create an alert
        
        Args:
            alert_type: Type of alert
            severity: Severity level
            student_name: Student name
            message: Alert message
            details: Additional details
            
        Returns:
            Alert dictionary
        """
        alert = {
            'id': len(self.alert_history) + 1,
            'type': alert_type,
            'severity': severity,
            'student_name': student_name,
            'message': message,
            'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            'details': details or {}
        }
        
        # Update statistics
        self.stats['total_alerts'] += 1
        self.stats['alerts_by_type'][alert_type] += 1
        self.stats['alerts_by_severity'][severity] += 1
        self.stats['alerts_by_student'][student_name] += 1
        
        # Track violation
        if alert_type != self.ALERT_ABSENT:
            self.student_violations[student_name].append({
                'type': alert_type,
                'timestamp': datetime.now()
            })
        
        # Store in history
        self.alert_history.append(alert)
        
        # Process alert
        self.process_alert(alert)
        
        return alert
    
    def process_alert(self, alert):
        """
        Process and send alert through configured channels
        
        Args:
            alert: Alert dictionary
        """
        # Console alert
        if self.config['enable_console_alerts']:
            self._send_console_alert(alert)
        
        # File alert
        if self.config['enable_file_alerts']:
            self._send_file_alert(alert)
        
        # Email alert
        if self.config['enable_email_alerts']:
            self._send_email_alert(alert)
        
        # Sound alert
        if self.config['enable_sound_alerts']:
            self._play_alert_sound(alert)
    
    def _send_console_alert(self, alert):
        """Print alert to console"""
        severity_colors = {
            self.SEVERITY_INFO: '\033[94m',      # Blue
            self.SEVERITY_WARNING: '\033[93m',   # Yellow
            self.SEVERITY_CRITICAL: '\033[91m'   # Red
        }
        reset_color = '\033[0m'
        
        color = severity_colors.get(alert['severity'], '')
        
        print(f"\n{color}{'='*70}")
        print(f"[{alert['severity']}] ALERT #{alert['id']}")
        print(f"Type: {alert['type']}")
        print(f"Student: {alert['student_name']}")
        print(f"Time: {alert['timestamp']}")
        print(f"Message: {alert['message']}")
        if alert['details']:
            print(f"Details: {alert['details']}")
        print(f"{'='*70}{reset_color}\n")
    
    def _send_file_alert(self, alert):
        """Save alert to file"""
        alert_dir = 'data/alerts'
        os.makedirs(alert_dir, exist_ok=True)
        
        date_str = datetime.now().strftime("%Y-%m-%d")
        alert_file = os.path.join(alert_dir, f"{date_str}.json")
        
        # Load existing alerts
        if os.path.exists(alert_file):
            with open(alert_file, 'r') as f:
                alerts = json.load(f)
        else:
            alerts = []
        
        alerts.append(alert)
        
        with open(alert_file, 'w') as f:
            json.dump(alerts, f, indent=4)
    
    def _send_email_alert(self, alert):
        """Send alert via email"""
        if not self.config['email_sender'] or not self.config['email_recipients']:
            return
        
        try:
            msg = MIMEMultipart()
            msg['From'] = self.config['email_sender']
            msg['To'] = ', '.join(self.config['email_recipients'])
            msg['Subject'] = f"[{alert['severity']}] Classroom Alert - {alert['type']}"
            
            body = f"""
Classroom Monitoring Alert

Alert ID: {alert['id']}
Type: {alert['type']}
Severity: {alert['severity']}
Student: {alert['student_name']}
Time: {alert['timestamp']}

Message: {alert['message']}

Details: {json.dumps(alert['details'], indent=2)}

---
Automated Smart Classroom Monitoring System
            """
            
            msg.attach(MIMEText(body, 'plain'))
            
            # Send email
            server = smtplib.SMTP(
                self.config['email_smtp_server'], 
                self.config['email_smtp_port']
            )
            server.starttls()
            server.login(self.config['email_sender'], self.config['email_password'])
            server.send_message(msg)
            server.quit()
            
            print(f"Email alert sent for Alert #{alert['id']}")
        
        except Exception as e:
            print(f"Failed to send email alert: {e}")
    
    def _play_alert_sound(self, alert):
        """Play alert sound (platform-dependent)"""
        try:
            import platform
            import subprocess
            
            if platform.system() == 'Darwin':  # macOS
                subprocess.run(['afplay', '/System/Library/Sounds/Ping.aiff'])
            elif platform.system() == 'Windows':
                import winsound
                winsound.MessageBeep()
            else:  # Linux
                subprocess.run(['paplay', '/usr/share/sounds/freedesktop/stereo/bell.oga'])
        except Exception as e:
            pass  # Silently fail if sound not available
    
    def _check_cooldown(self, student_name, alert_type):
        """Check if alert cooldown period has passed"""
        key = f"{student_name}_{alert_type}"
        last_time = self.last_alert_time[key]
        cooldown = timedelta(seconds=self.config['alert_cooldown'])
        
        return datetime.now() - last_time > cooldown
    
    def _update_last_alert_time(self, student_name, alert_type):
        """Update last alert time"""
        key = f"{student_name}_{alert_type}"
        self.last_alert_time[key] = datetime.now()
    
    def get_alert_summary(self):
        """Get summary of all alerts"""
        return {
            'total_alerts': self.stats['total_alerts'],
            'by_type': dict(self.stats['alerts_by_type']),
            'by_severity': dict(self.stats['alerts_by_severity']),
            'by_student': dict(self.stats['alerts_by_student']),
            'recent_alerts': self.alert_history[-10:]  # Last 10 alerts
        }
    
    def get_student_report(self, student_name):
        """
        Get detailed report for a student
        
        Args:
            student_name: Name of student
            
        Returns:
            Student report dictionary
        """
        student_alerts = [
            a for a in self.alert_history 
            if a['student_name'] == student_name
        ]
        
        return {
            'student_name': student_name,
            'total_alerts': len(student_alerts),
            'violations': len(self.student_violations[student_name]),
            'alerts': student_alerts,
            'alert_types': {
                alert_type: sum(1 for a in student_alerts if a['type'] == alert_type)
                for alert_type in set(a['type'] for a in student_alerts)
            }
        }
    
    def export_daily_report(self):
        """Export daily alert report"""
        report_dir = 'data/reports'
        os.makedirs(report_dir, exist_ok=True)
        
        date_str = datetime.now().strftime("%Y-%m-%d")
        report_file = os.path.join(report_dir, f"report_{date_str}.json")
        
        report = {
            'date': date_str,
            'summary': self.get_alert_summary(),
            'student_reports': {
                student: self.get_student_report(student)
                for student in self.stats['alerts_by_student'].keys()
            }
        }
        
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=4)
        
        print(f"Daily report exported to {report_file}")
        return report_file
    
    def reset(self):
        """Reset alert system (for new session)"""
        self.active_alerts = {}
        self.alert_history = []
        self.student_violations = defaultdict(list)
        self.last_alert_time = defaultdict(lambda: datetime.min)
        self.stats = {
            'total_alerts': 0,
            'alerts_by_type': defaultdict(int),
            'alerts_by_severity': defaultdict(int),
            'alerts_by_student': defaultdict(int)
        }


# Example usage
if __name__ == "__main__":
    print("=== Alert System Demo ===\n")
    
    # Initialize alert system
    alert_system = AlertSystem({
        'sleep_duration_threshold': 10,  # Lower threshold for demo
        'talk_duration_threshold': 15,
        'alert_cooldown': 30
    })
    
    # Simulate some alerts
    print("Simulating classroom alerts...\n")
    
    # Sleeping alert
    alert_system.create_alert(
        alert_type=AlertSystem.ALERT_SLEEPING,
        severity=AlertSystem.SEVERITY_WARNING,
        student_name="John Doe",
        message="John Doe has been sleeping for 65 seconds",
        details={'duration': 65, 'ear': 0.18}
    )
    
    # Phone usage alert
    alert_system.create_alert(
        alert_type=AlertSystem.ALERT_PHONE_USAGE,
        severity=AlertSystem.SEVERITY_CRITICAL,
        student_name="Jane Smith",
        message="Jane Smith detected using mobile phone",
        details={'confidence': 0.87}
    )
    
    # Talking alert
    alert_system.create_alert(
        alert_type=AlertSystem.ALERT_TALKING,
        severity=AlertSystem.SEVERITY_INFO,
        student_name="John Doe",
        message="John Doe has been talking for 125 seconds",
        details={'duration': 125, 'mar': 0.75}
    )
    
    # Get summary
    print("\n=== Alert Summary ===")
    summary = alert_system.get_alert_summary()
    print(json.dumps(summary, indent=2))
    
    # Export report
    print("\n=== Exporting Daily Report ===")
    report_file = alert_system.export_daily_report()
