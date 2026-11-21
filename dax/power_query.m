// Reference copy of the Power Query (M) steps used to prepare the `Sales` table.
// The authoritative version is inside dashboard/online_retail_retention.pbix.
// Replace the file path with the location of your own copy of online_retail_II.csv.
let
    Source = Csv.Document(
        File.Contents("C:\path\to\online_retail_II.csv"),
        [Delimiter = ",", Columns = 8, Encoding = 1256, QuoteStyle = QuoteStyle.None]
    ),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    // Invoice must stay text: cancellations start with "C"
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {
        {"Invoice", type text}, {"StockCode", type text}, {"Description", type text},
        {"Quantity", Int64.Type}, {"InvoiceDate", type datetime}, {"Price", type number},
        {"Customer ID", Int64.Type}, {"Country", type text}
    }),
    // Customers without an ID cannot be tracked over time
    #"Removed Null Customers" = Table.SelectRows(#"Changed Type", each [Customer ID] <> null),
    #"Added Revenue" = Table.AddColumn(#"Removed Null Customers", "Revenue", each [Quantity] * [Price], type number),
    #"Added IsReturn" = Table.AddColumn(#"Added Revenue", "IsReturn", each Text.StartsWith([Invoice], "C"), type logical),
    #"Added InvoiceDay" = Table.AddColumn(#"Added IsReturn", "InvoiceDay", each DateTime.Date([InvoiceDate]), type date)
in
    #"Added InvoiceDay"
