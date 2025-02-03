import os

# Read the value of CICDENV from the environment variables, default to "env4" if not set
env = os.getenv("CICDENV", "env4")
