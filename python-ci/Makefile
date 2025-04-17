# Nama file utama Flask
APP=app.py

# Virtual environment directory
VENV=venv

.PHONY: run install clean test

# Install dependencies dan setup virtual environment
install:
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt

# Jalankan aplikasi Flask
run:
	$(VENV)/bin/python $(APP)

# Bersihkan cache dan virtual environment
clean:
	rm -rf $(VENV)
	rm -rf __pycache__

# Run tests dengan pytest
test:
	$(VENV)/bin/pytest tests/
