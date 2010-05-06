// waveformDlg.cpp : implementation file
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
// CWaveformDlg dialog

CWaveformDlg::CWaveformDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CWaveformDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CWaveformDlg)
	m_amplitude = -30.0;
	m_frequency = 500.0;
	m_dutyCycle =  50.0;
	//}}AFX_DATA_INIT
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CWaveformDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CWaveformDlg)
	DDX_Control(pDX, IDC_DUTY_CYCLE, m_dutyCycleEdit);
	DDX_Text(pDX, IDC_AMPLITUDE, m_amplitude);
	DDX_Text(pDX, IDC_FREQUENCY, m_frequency);
	DDX_Text(pDX, IDC_DUTY_CYCLE, m_dutyCycle);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CWaveformDlg, CDialog)
	//{{AFX_MSG_MAP(CWaveformDlg)
	ON_BN_CLICKED(IDC_SQUARE, OnSquare)
	ON_BN_CLICKED(IDC_SINE, OnSine)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CWaveformDlg message handlers

BOOL CWaveformDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	SetIcon(m_hIcon, TRUE);  // big icon
	SetIcon(m_hIcon, FALSE); // small icon
	
	CenterWindow(GetDesktopWindow());

    CheckRadioButton(IDC_SINE, IDC_SQUARE, IDC_SQUARE);

	return TRUE;
}

void CWaveformDlg::OnSquare() 
{
    m_dutyCycleEdit.EnableWindow(TRUE);
}

void CWaveformDlg::OnSine() 
{
    m_dutyCycleEdit.EnableWindow(FALSE);
}
