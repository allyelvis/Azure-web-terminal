from django.http import JsonResponse
import subprocess
import json

def execute_command(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        command = data.get('command', '')

        if not command.startswith('az'):
            return JsonResponse({'output': 'Invalid command'}, status=400)

        try:
            result = subprocess.run(command.split(), capture_output=True, text=True)
            return JsonResponse({'output': result.stdout or result.stderr})
        except Exception as e:
            return JsonResponse({'output': str(e)}, status=500)
