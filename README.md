# Signature Forgery Detection System

Setup:
    MacOS: 
        activate enviroment : 
        install openCV      : pip install opencv-python
        install matplotlib  : pip install matplotlib
        install tensorflow  : pip install tensorflow

    Windows: 
        activate enviroment : env\Scripts\activate
        install openCV      : pip install opencv-python
        install matplotlib  : pip install matplotlib
        install tensorflow  : pip install tensorflow



Error Handling:
    Windows:
        For Python vertual enviroment

        For access error -->

        ERROR: 
            Scripts\Activate.ps1 cannot be loaded because running scripts is disabled on this system. For more information, see about_Execution_Policies at 
            https:/go.microsoft.com/fwlink/?LinkID=135170.
            At line:1 char:1
            + env\Scripts\activate
            + ~~~~~~~~~~~~~~~~~~~~
                + CategoryInfo          : SecurityError: (:) [], PSSecurityException
                + FullyQualifiedErrorId : UnauthorizedAccess

        SOLUTION: 
            Set-ExecutionPolicy Unrestricted -Scope Process
            ** (This would allow running virtualenv in the current PowerShell session)

# Start Backend

Navigate to the file location
    cd SignatureForgeryDetectionSystem/Apllication/Backend

Start the FastAPI Server:
    uvicorn Signature_Forgery_Backend:app --host 0.0.0.0 --port 8000 --reload

Test the API Using Swagger UI
    http://127.0.0.1:8000/docs
    
pip install uvicorn
pip install fastapi
pip install python-multipart