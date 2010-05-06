// waveform.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "waveform.h"
#include "waveformDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CWaveformApp

BEGIN_MESSAGE_MAP(CWaveformApp, CWinApp)
	//{{AFX_MSG_MAP(CWaveformApp)
	//}}AFX_MSG
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CWaveformApp construction

CWaveformApp::CWaveformApp()
	: CWinApp()
{
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CWaveformApp object

CWaveformApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CWaveformApp initialization

BOOL CWaveformApp::InitInstance()
{
	CWaveformDlg dlg;
	m_pMainWnd = &dlg;
	int nResponse = dlg.DoModal();

	// Since the dialog has been closed, return FALSE so that we exit the
	//  application, rather than start the application's message pump.
	return FALSE;
}
