codeunit 66001 "CREDIT Install EasyInvoiceAPP"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase();
    var
        myAppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(myAppInfo); // Get info about the currently executing module

        if myAppInfo.DataVersion = Version.Create(0, 0, 0, 0) then // A 'DataVersion' of 0.0.0.0 indicates a 'fresh/new' install
            HandleFreshInstall
        else
            HandleReinstall; // If not a fresh install, then we are Re-installing the same version of the extension
    end;

    local procedure HandleFreshInstall();
    var
        WebserviceMgt: Codeunit "Web Service Management";
        Webservtype: Option "Web Service";

    begin
        //Create webservice EasyInvoice
        //WebserviceMgt.CreateWebService(Webservtype,66000,'EasyInvoice',true);     
        WebserviceMgt.CreateTenantWebService(Webservtype, 66000, 'EasyInvoice', true);
    end;

    local procedure HandleReinstall();
    begin
        // Do work needed when reinstalling the same version of this extension back on this tenant.
        // Some possible usages:
        // - Service callback/telemetry indicating that extension was reinstalled
        // - Data 'patchup' work, for example, detecting if new 'base' records have been changed while you have been working 'offline'.
        // - Setup 'welcome back' messaging for next user access.
    end;
}