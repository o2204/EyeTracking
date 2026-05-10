import os

input_file = '/home/omar/Downloads/deepseek/deepseek_dart_20260509_375435.dart'
output_file = '/home/omar/EyeTracking/ui/lib/screens/admin_dashboard_screen.dart'

with open(input_file, 'r') as f:
    content = f.read()

content = content.replace('LoginScreen', 'AdminLoginScreen')
content = content.replace('DashboardScreen', 'AdminDashboardScreen')
content = content.replace('AppColors', 'AdminColors')
content = content.replace('EyeIntelligenceApp', 'AdminApp')
# Fix navigation mapping in AdminLoginScreen to go to AdminDashboardScreen instead of DashboardScreen
# Actually it's already replaced above by string replace!

with open(output_file, 'w') as f:
    f.write(content)

print("Renamed and copied deepseek dart file to admin_dashboard_screen.dart")
