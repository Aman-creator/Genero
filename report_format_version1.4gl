SCHEMA custdemo

REPORT order_list(order_rep)

    DEFINE order_rep RECORD
        order_num LIKE orders.order_num,
        item_desc LIKE stock.description,
        store_name LIKE customer.store_name,
        fac_name LIKE factory.fac_name,
        quantity LIKE items.quantity
    END RECORD

     ORDER EXTERNAL BY  order_rep.order_num

  FORMAT


    PAGE HEADER
        SKIP 2 LINES
        PRINT COLUMN 30, "order Listing"
        PRINT COLUMN 30, "As of ", TODAY USING "mm/dd/yy"
        SKIP 2 LINES

        PRINT  COLUMN 2, "order number #",
          COLUMN 20, "item description",
          COLUMN 40, "store name",
          COLUMN 60, "factory name",
          COLUMN 80, "quantity"

         SKIP 2 LINES       
      
   
   ON EVERY ROW 
     PRINT COLUMN 5, order_rep.order_num USING "##",
           COLUMN 20, order_rep.item_desc CLIPPED,
           COLUMN 40, order_rep.store_name CLIPPED,
           COLUMN 60, order_rep.fac_name CLIPPED,
           COLUMN 80, order_rep.quantity CLIPPED 
           #SKIP 1 LINE
    {AFTER  GROUP OF order_rep.fac_name
    SKIP TO TOP OF PAGE}

        ON LAST ROW
        SKIP 1 LINE
        PRINT "TOTAL number of orders: ", 
           COUNT(*) USING "#,###"


   PAGE TRAILER
    SKIP 2 LINES
    PRINT COLUMN 30, "-", PAGENO USING "<<", " -"

    
END REPORT 