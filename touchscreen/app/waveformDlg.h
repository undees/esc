// waveformDlg.h : header file
//

#if !defined(AFX_WAVEFORMDLG_H__72B23995_E30F_42A3_AE9E_A386BFC0140F__INCLUDED_)
#define AFX_WAVEFORMDLG_H__72B23995_E30F_42A3_AE9E_A386BFC0140F__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

/////////////////////////////////////////////////////////////////////////////
// CWaveformDlg dialog

class CWaveformDlg : public CDialog
{
// Construction
public:
	CWaveformDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CWaveformDlg)
	enum { IDD = IDD_WAVEFORM_DIALOG };
	CEdit	m_dutyCycleEdit;
	double	m_amplitude;
	double	m_frequency;
	double	m_dutyCycle;
	//}}AFX_DATA

	//{{AFX_VIRTUAL(CWaveformDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	//{{AFX_MSG(CWaveformDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSquare();
	afx_msg void OnSine();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}

#endif // !defined(AFX_WAVEFORMDLG_H__72B23995_E30F_42A3_AE9E_A386BFC0140F__INCLUDED_)
