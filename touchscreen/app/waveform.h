// waveform.h : main header file for the WAVEFORM application
//

#if !defined(AFX_WAVEFORM_H__BFA7BB23_1DD1_41FF_9765_3B0F23AA3730__INCLUDED_)
#define AFX_WAVEFORM_H__BFA7BB23_1DD1_41FF_9765_3B0F23AA3730__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CWaveformApp:
// See waveform.cpp for the implementation of this class
//

class CWaveformApp : public CWinApp
{
public:
	CWaveformApp();

// Overrides
	//{{AFX_VIRTUAL(CWaveformApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CWaveformApp)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}

#endif // !defined(AFX_WAVEFORM_H__BFA7BB23_1DD1_41FF_9765_3B0F23AA3730__INCLUDED_)
