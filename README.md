# run server
fastapi dev --host 0.0.0.0 main.py
# 启动
uvicorn app.app:app --host 0.0.0.0 --port 8000