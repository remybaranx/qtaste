/*
    Copyright 2007-2009 QSpin - www.qspin.be

    This file is part of QTaste framework.

    QTaste is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    QTaste is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with QTaste. If not, see <http://www.gnu.org/licenses/>.
*/

package com.qspin.qtaste.ui.tools;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;

import javax.swing.JOptionPane;

import org.apache.log4j.Logger;
import org.python.core.PyException;
import org.python.util.PythonInterpreter;

import com.qspin.qtaste.config.StaticConfiguration;
import com.qspin.qtaste.util.FileUtilities;
import com.qspin.qtaste.util.Log4jLoggerFactory;

public class PythonTestScript {
    private static Logger logger = Log4jLoggerFactory.getLogger(PythonTestScript.class);
    private static final String LINE_SEPARATOR = System.getProperty("line.separator");

	private File m_ScriptFile;
	private File m_ScriptFileDir;
	private String m_TestSuiteDir;
	private File m_ScriptDoc = null;
	private File m_ScriptData = null;
	private File m_ScriptReq = null;
	
	public PythonTestScript(File file, String testSuiteDir) {
		m_ScriptFile = file;
		m_ScriptFileDir = file.getParentFile();
		m_TestSuiteDir = testSuiteDir;
	}
	public File getTestScriptFile() {
		return m_ScriptFile;
	}
	public void setTestScriptFile(File file) {
		m_ScriptFile = file;
		m_ScriptFileDir = file.getParentFile();
		m_ScriptDoc = null;
		m_ScriptData = null;
		m_ScriptReq = null;
		
	}
	public boolean isDocSynchronized() {
		File doc = getTestcaseDoc();
        if ((doc != null) && (m_ScriptFile != null)) {
            long lastTestCaseModifiedDate = m_ScriptFile.lastModified();
            File testcaseData = this.getTestcaseData();
            if (testcaseData != null) {
                lastTestCaseModifiedDate = Math.max(lastTestCaseModifiedDate, testcaseData.lastModified());
            }
            File testRequirement = this.getTestcaseRequirements();
            if (testRequirement != null) {
                lastTestCaseModifiedDate = Math.max(lastTestCaseModifiedDate, testRequirement.lastModified());
            }
            long lastTestDocModifiedDate = doc.lastModified();
            return lastTestCaseModifiedDate < lastTestDocModifiedDate;
        }
		return false;
	}
	public File generateDoc() {
        File testcaseDoc = null;
        String xmlDocFilename = m_ScriptFileDir + "/" + StaticConfiguration.TEST_SCRIPT_DOC_XML_FILENAME;
        File xmlDocFile = new File(xmlDocFilename);
        String htmlDocFilename = m_ScriptFileDir + "/" + StaticConfiguration.TEST_SCRIPT_DOC_HTML_FILENAME;
        File htmlDocFile = new File(htmlDocFilename);
        htmlDocFile.delete();
        try {
            String testCasename = m_ScriptFileDir.getCanonicalPath();
            // get the current TestSuitesDirectory
            m_TestSuiteDir = m_TestSuiteDir.replace("\\", "/");
            StringWriter output = new StringWriter();
            PythonInterpreter interp = new PythonInterpreter(new org.python.core.PyStringMap(), new org.python.core.PySystemState());
            interp.setOut(output);
            interp.setErr(output);
            interp.cleanup();
            String args = "import sys;sys.argv[1:]= ['-f', '-s', '-Otestscriptdoc_xmlformatter'";
            if (new File(m_TestSuiteDir).getCanonicalFile() == new File("TestSuites").getCanonicalFile()) {
            	args += ",\"-DrootTestSuiteDir=" + m_TestSuiteDir + "\"";
            }
            args+=", r'" + testCasename + "']";
            interp.exec(args);
            interp.exec("__name__ = '__main__'");
            interp.exec("execfile(r'" + StaticConfiguration.JYTHON_QTASTE_SCRIPTS + "/pythondoc.py')");
            interp.cleanup();
            interp = null;
            if (xmlDocFile.exists()) {
                final String[] args2 = new String[]{"-XSLTC", "-XT", "-IN", xmlDocFilename, "-XSL", StaticConfiguration.TEST_SCRIPT_DOC_TOOLS_DIR + "/testscriptdoc_xml2html.xsl", "-OUT", htmlDocFilename};
                org.apache.xalan.xslt.Process.main(args2);
                xmlDocFile.delete();
                String outputString = output.toString();
                if (outputString.endsWith(StaticConfiguration.TEST_SCRIPT_DOC_XML_FILENAME + " ok" + LINE_SEPARATOR)) {
                    int endOfBeforeLastLine = outputString.lastIndexOf(LINE_SEPARATOR, outputString.length() - (LINE_SEPARATOR.length() + 4));
                    if (endOfBeforeLastLine == -1) {
                        outputString = null;
                    } else {
                        outputString = outputString.substring(0, endOfBeforeLastLine);
                    }
                }
                if (outputString != null) {
                    JOptionPane.showMessageDialog(null, outputString, "Documentation generation warning", JOptionPane.WARNING_MESSAGE);
                }
            } else {
                JOptionPane.showMessageDialog(null , output, "Documentation generation error", JOptionPane.ERROR_MESSAGE);
            }
            testcaseDoc = getTestcaseDoc();
        } catch (PyException ex) {
            logger.error(ex);
        } catch (Exception ex) {
            logger.error(ex);
        }
        return testcaseDoc;		
	}
	
    public File getTestcaseData() {
    	if (m_ScriptData==null) {
        	m_ScriptData = findFileIn(StaticConfiguration.TEST_DATA_FILENAME, m_ScriptFileDir);
    	}
    	return m_ScriptData;

    }
	
    public File getTestcaseDoc() {
    	if (m_ScriptDoc==null) {
        	m_ScriptDoc = findFileIn(StaticConfiguration.TEST_SCRIPT_DOC_HTML_FILENAME, m_ScriptFileDir);
    	}
    	return m_ScriptDoc;
    }
    
    public File getTestcaseRequirements() {
    	if (m_ScriptReq==null) {
    		m_ScriptReq = findFileIn(StaticConfiguration.TEST_REQUIREMENTS_FILENAME, m_ScriptFileDir);
    		if ( m_ScriptReq == null )
    		{
    			//create an empty file
    			try {
    				m_ScriptReq = new File(m_ScriptFileDir, StaticConfiguration.TEST_REQUIREMENTS_FILENAME);
    				File templateFile = new File(StaticConfiguration.CONFIG_DIRECTORY + "/templates/TestScript", StaticConfiguration.TEST_REQUIREMENTS_FILENAME);
    				FileUtilities.copy(templateFile, m_ScriptReq);
				} catch (IOException e) {
					m_ScriptReq = null;
					logger.error(e);
				}
    		}
    	}
    	return m_ScriptReq;
    }
    
    protected File findFileIn(String pFileName, File pDirectory)
    {
    	File[] childFiles = FileUtilities.listSortedFiles(pDirectory);
        for (int i = 0; i < childFiles.length; i++) {
            if (childFiles[i].getName().equalsIgnoreCase(pFileName)) {
                return childFiles[i];
            }
        }
        return null;
    }
}
