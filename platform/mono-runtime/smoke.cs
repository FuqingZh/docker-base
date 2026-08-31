using System;
using System.Data;

// Exercise framework behavior, not just the existence of System.Data.dll.
internal static class Smoke
{
    private static int Main()
    {
        using (var table = new DataTable("assembly_probe"))
        {
            table.Columns.Add("sample", typeof(string));
            table.Columns.Add("intensity", typeof(double));
            table.Rows.Add("QC_1", 100.0);
            DataRow[] rows = table.Select("intensity >= 100");
            if (rows.Length != 1 || (string)rows[0]["sample"] != "QC_1")
                throw new InvalidOperationException("System.Data behavior check failed");
            Console.WriteLine("PASS System.Data DataTable/Select: " + typeof(DataTable).Assembly.FullName);
        }
        return 0;
    }
}
