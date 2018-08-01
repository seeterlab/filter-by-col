# NAME

    filter.pl - Filter file_to_filter.txt with reference_file.txt
    See examples bellow.

# SYNOPSIS

    filter.pl [-v|--invert-match] [-a|--key1 num,num,...] [-b|--key2 num,num,...] reference_file.txt [file_to_filter.txt]

or

    filter.pl [-v|--invert-match] [-k|--key num,num,...] reference_file.txt [file_to_filter.txt]

or

    filter.pl [--help|--man]

# OPTIONS

- `-v|--invert-match`

    If specified, match is inverted: print lines that do not match those of **reference\_file.txt**.

- `-a|--key1`

    Specify one based and comma separated column numbers to consider for `reference\_file.txt`.
    Default value: 1

- `-b|--key2`

    Specify one based and comma separated column numbers to consider for `file\_to\_filter.txt`.
    Default value: 1

- `-k|--key`

    Specify one based and comma separated column numbers to consider for `reference\_file.txt` and `file\_to\_filter.txt`.
    Default value: 1

- `-help`

    Print a brief help message and exits.

- `-man`

    Prints the manual page and exits.

# DESCRIPTION

**filer.pl** filters **file\_to\_filter.txt** with **reference\_file.txt** based on the specified key columns.
Files do not have to be sorted.
If **file\_to\_filter.txt** is omitted, stdin is read instead.

# EXAMPLES

## Same key columns order in both files

If the key column numbers are in the same order in both files, you can specify those numbers with **-k** (or --key):

    filter.pl -k 1,2 reference_file.txt file_to_filter.txt

## Different key columns order in each file

If the key column numbers are NOT in the same order in both files, use **-a** and **-b** (or --key1 and --key2):

    filter.pl -a 1,2 -b 3,1 reference_file.txt file_to_filter.txt

## Reading from stdin

If **file\_to\_filter.txt** is omitted, sdtin is read instead:

    cat file_to_filter.txt | filter.pl -k 1,2 reference_file.txt

# SAMPLE FILES

If **reference\_file.txt** and **file\_to\_filter.txt** have the following content:

## reference\_file.txt

    1   abc     13259250
    1   def     13282200
    1   ijkl    13323300
    1   mnop    13345050
    1   qr      13371150
    1   stuvx   13475700
    2   XYZ     2437050
    2   TOTO    2459700
    2   TITI    2591100
    2   THING   2615700
    2   OTHER   2657400

## file\_to\_filter.txt

    1325 13253660        1 260
    ijkl 13255820        1 200
    1325 13259040        1 380
    1327 13278020        1 200
    1327 13278420        1 220
    1331 13316320        1 200
    mnop 13319760        1 200
    1332 13322380        1 200
    1335 13359500        1 300
    1335 13360140        1 280
    abc 13364080         1 340
    1336 13368240        1 460
    1346 13467580        1 200
    1353 13537860        1 200
    1354 13542460        1 440
    1354 13544660        1 200
    1354 13545160        1 420
    5117 5117260         2 260
    5166 5167060         2 200
    TOTO 5169100         2 220
    5169 5169680         2 320
    5214 5215020         2 320
    5390 5391120         2 660
    5391 5391820         2 220
    5419 5419660         2 200
    5509 5510260         2 620
    5511 5511820         2 220
    XYZ 5512820          2 440
    5539 5539700         2 200

## Showing matching lines in file\_to\_filter.txt

The following command produces the output below:

    filter.pl -a 1,2 -b 3,1 reference_file.txt file_to_filter.txt

    ijkl 13255820        1 200
    mnop 13319760        1 200
    abc  13364080        1 340
    TOTO 5169100         2 220
    XYZ  5512820         2 440

## Showing NOT matching lines in file\_to\_filter.txt

The following command produces the output below:

    filter.pl -v -a 1,2 -b 3,1 reference_file.txt file_to_filter.txt

    1325 13253660        1 260
    1325 13259040        1 380
    1327 13278020        1 200
    1327 13278420        1 220
    1331 13316320        1 200
    1332 13322380        1 200
    1335 13359500        1 300
    1335 13360140        1 280
    1336 13368240        1 460
    1346 13467580        1 200
    1353 13537860        1 200
    1354 13542460        1 440
    1354 13544660        1 200
    1354 13545160        1 420
    5117 5117260         2 260
    5166 5167060         2 200
    5169 5169680         2 320
    5214 5215020         2 320
    5390 5391120         2 660
    5391 5391820         2 220
    5419 5419660         2 200
    5509 5510260         2 620
    5511 5511820         2 220
    5539 5539700         2 200
