

// crear archivo txt adicionar lineas  leerlo

using System;
using System.IO;

class Test 
{
    public static void Main() 
    {
        string path = @"c:\temp\MyTest.txt";
        // This text is added only once to the file.
        if (!File.Exists(path)) 
        {
            // Create a file to write to.
            using (StreamWriter sw = File.CreateText(path)) 
            {
                sw.WriteLine("Hello");
                sw.WriteLine("And");
                sw.WriteLine("Welcome");
            }	
        }

        // This text is always added, making the file longer over time
        // if it is not deleted.
        using (StreamWriter sw = File.AppendText(path)) 
        {
            sw.WriteLine("This");
            sw.WriteLine("is Extra");
            sw.WriteLine("Text");
        }	

        // Open the file to read from.
        using (StreamReader sr = File.OpenText(path)) 
        {
            string s = "";
            while ((s = sr.ReadLine()) != null) 
            {
                Console.WriteLine(s);
            }
        }
    }
}



// descargarlo luego de crearlo

public void descargarPDF(string nombrePDF)
    {
        string pathPDF = HttpContext.Current.Server.MapPath("~/PDF/" + nombrePDF);
        Response.Clear();
        if (Path.GetExtension(pathPDF) == "txt")
        {
            Response.ContentType = "application/text";
        }
        else
        {
            Response.ContentType = "application/pdf";
        }
        
        Response.AppendHeader("Content-Disposition", "attachment; filename=" + nombrePDF + "");
        Response.TransmitFile(pathPDF);
        Response.End();



    }
