@ECHO OFF
SETLOCAL

SET root_path=%~dp0

REM exclude the ebm_native directory so that it doesn't delete our existing source files which we mirror separately
robocopy "%root_path%\" "%root_path%..\tmp\R" /S /PURGE /R:2 /NP /XF Makevars /XF Makevars.interpret /XF build_R.bat /XF cran_lic.txt /XF LICENSE /XD ebm_native
ECHO robocopy returned error code %ERRORLEVEL%
IF %ERRORLEVEL% GEQ 8 (
   EXIT /B %ERRORLEVEL%
)

copy /Y "%root_path%src\Makevars.interpret" "%root_path%..\tmp\R\src\Makevars"

copy /Y "%root_path%cran_lic.txt" "%root_path%..\tmp\R\LICENSE"

robocopy "%root_path%..\shared\ebm_native" "%root_path%..\tmp\R\src\ebm_native" /S /PURGE /R:2 /NP /XF interpret.sln /XF ebm_native.vcxproj /XF ebm_native.vcxproj.user /XF PrecompiledHeader.cpp /XF DllMainEbmNative.cpp /XF wrap_func.cpp /XF ebm_native_exports.def /XF ebm_native_exports.txt /XF style.md /XD .vs /XD ebm_native_test /XD TestResults
ECHO robocopy returned error code %ERRORLEVEL%
IF %ERRORLEVEL% GEQ 8 (
   EXIT /B %ERRORLEVEL%
)

del "%root_path%..\staging\interpret_*.tar.gz"
mkdir "%root_path%..\staging"
pushd "%root_path%..\staging"
Rcmd build "%root_path%..\tmp\R"
popd

R CMD check -o "%root_path%..\tmp\R" --as-cran "%root_path%..\staging\interpret_*.tar.gz"
