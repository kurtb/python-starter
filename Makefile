# Inspiration from
# https://blog.byronjsmith.com/makefile-shortcuts.html
# https://github.com/edx/xblock

.PHONY: jupyter requirements upgrade clean

define PROJECT_HELP_MSG

Usage:
    make help           show help message
    make $(VENV)           creates a new virtual environment

    make clean          cleans up environemnt

    make requirements   installs dev requirements
    make upgrade        upgrades packages and regenerates all requirements files

    make jupyter        starts Jupyter notebook server from current venv

endef
export PROJECT_HELP_MSG

VENV = .env

# set the venv path for commands to not require sourcing the env
export VIRTUAL_ENV := $(abspath ${VENV})
export PATH := ${VIRTUAL_ENV}/bin:${PATH}

help:
	@echo "$$PROJECT_HELP_MSG"

$(VENV):
	python3 -m venv $@
	. $(VENV)/bin/activate; pip install -U pip wheel

clean:
	rm -rf $(VENV)

requirements: # Install requirements
	pip install -r ./requirements/dev.txt
	pip install -e .

jupyter-setup:
	jupyter nbextension enable --py widgetsnbextension
	jupyter labextension install @jupyter-widgets/jupyterlab-manager

jupyter:
	jupyter lab --ip=0.0.0.0 --port=8080

upgrade: export CUSTOM_COMPILE_COMMAND=make upgrade
upgrade:
	# Install pip-tools first so that the subsequent commands can work
	pip install -r requirements/pip-tools.txt
	# Then upgrade packages. Order matters with the below. They should be upgraded in the order of dependencies.
	pip-compile --upgrade requirements/pip-tools.in
	pip-compile --upgrade setup.py -o requirements/requirements.txt
	pip-compile --upgrade requirements/dev.in
