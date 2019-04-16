		 public static void exportMatchedClientAndSettlementFiles() {
			         
			displayBox.Text +="\r\n Exporting matched client records....";
			statusLabel.Text ="Exporting matched client client records....";
			string sql_query ="";
            try
            {
					        
                string outputFileLoc = outputFile.Substring(0,outputFile.LastIndexOf('.'))+"_unsettled_not_in_office.csv";
		if(File.Exists(outputFileLoc))
		{
			File.Delete(outputFileLoc);
		}
		displayBox.Text +="\r\nExporting results to  " + outputFileLoc;
		statusLabel.Text ="Exporting results to  " + outputFileLoc;
		string columnName="";
		string columnValue="";
		
        using (System.IO.StreamWriter fs = new System.IO.StreamWriter(outputFileLoc))
                    {


                        foreach(DataColumn col in  comparisonResultsTab.Columns){
								if (col.Name.Contains(","))
                                columnName = "\"" + col.Name + "\"";
                                fs.Write(col.Name + ",");				
					}
					fs.WriteLine();
			  foreach (DataRow compRows in comparisonResultsTab.Rows){
							foreach(DataColumn col in compRows.Table.Columns){
									columnValue = col.Value;
                                if (columnValue.Contains(","))
                                    columnValue = "\"" + columnValue + "\"";

                                fs.Write(columnValue + ",");
                            }				
					}
					fs.WriteLine();
				   fs.Close();
                    }
                  //  displayBox.Text +="\r\nExport complete!" + outputFileLoc;
				//	statusLabel.Text ="\nExport complete!" + outputFileLoc;
				     MessageBox.Show("Client records that could not be found in the  Office server have been successfully exported to:\r\n"+outputFileLoc, "Recon");
            }
            catch (Exception e)
            {
				// displayBox.Text +="\r\n"+e.Message;
				 //displayBox.Text +="\r\n"+e.StackTrace;
				 statusLabel.Text =e.Message;
				  MessageBox.Show("Error exporting missing client records: "+e.Message, "Recon Tool - Error",MessageBoxButtons.OK,MessageBoxIcon.Warning);
				continueRunning =false;
		   }
        }