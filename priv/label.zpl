^XA
^LH20,20
^FO20,00^BQ,2,10
^FDLM,A <%= id %>^FS
^FO280,10^AD,N,15,10^FD<%= String.slice(id, 0, 6) |> String.upcase %>^FS
^FO280,50^AD,N,15,10^FD<%= String.slice(id, 6, 6) |> String.upcase %>^FS
^FO280,90^AD,N,15,10^FD<%= String.slice(id, 12, 6) |> String.upcase %>^FS
^FO280,130^AD,N,15,10^FD<%= String.slice(id, 18, 6) |> String.upcase %>^FS
^FO280,170^AD,N,10,10^FDCRTLABS.ORG^FS
^XZ
