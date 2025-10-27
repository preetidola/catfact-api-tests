# CatFact API Tests (Robot Framework)

This project contains automated tests for the public [CatFact API](https://catfact.ninja).

## Prerequisites
- Python 3.8 or newer
- pip (Python package installer)
- Anaconda/Miniconda if you prefer using conda

## Setup

1. **Unzip the archive**
   ```bash
   unzip catfact_api_tests.zip
   cd catfact_api_tests

2. Create and activate conda environment
   ```bash
   conda create -n catfactenv python=3.12
   conda activate catfactenv

3. Install dependencies
   pip install -r requirements.txt

4. Run the tests
   Once everything’s ready and you’re inside your `catfactenv`, run:
   ```bash
   robot tests/catfact_api_tests.robot

---------------
Optional: If you prefer Python’s built-in venv, you can create a virtual environment instead of conda. The steps are similar, just replace conda commands with python -m venv venv and activate accordingly.

## Test Coverage Summary

This test suite verifies the core functionality and reliability of the CatFact API.

/fact Endpoint
---------------
• Verifies the API returns HTTP 200.
• Validates the structure of a random cat fact.
• Checks that the `max_length` parameter limits fact length correctly.

 /facts Endpoint
----------------
• Confirms valid response schema and data structure.
• Validates `limit` parameter behavior and pagination consistency.
• Tests combined parameters (`limit` + `max_length`) for correctness.

 Edge & Default Cases
----------------------
• Ensures API defaults to 10 facts when `limit` is 0, negative, or missing.
• Validates `per_page` and `last_page` values align with expected defaults.

## Project Structure
catfact_api_tests/
│
├── tests/
│   └── catfact_api_tests.robot        # Main Robot Framework test suite
│
├── resources/
│   └── api_keywords.robot             # Reusable keywords for API requests & schema validation
│
├── requirements.txt                   # Python dependencies (RequestsLibrary, etc.)
├── README.md                          # Project documentation
└── logs/ or output/ (optional)        # Test results and execution logs




