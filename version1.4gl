IMPORT FGL report_format
IMPORT util 
SCHEMA custdemo


GLOBALS

DEFINE  order_arr    DYNAMIC ARRAY OF RECORD LIKE orders.*,
        customer_arr DYNAMIC ARRAY OF RECORD LIKE customer.*,
        item_arr     DYNAMIC ARRAY OF RECORD LIKE items.*,
        factory_arr  DYNAMIC ARRAY OF RECORD LIKE factory.*,
        stock_arr    DYNAMIC ARRAY OF RECORD LIKE stock.*,
        stock_check ARRAY[20] OF BOOLEAN 

        
## used for dictionary implementation 
TYPE ordt RECORD LIKE items.*
TYPE dt DYNAMIC ARRAY OF ordt
DEFINE item DICTIONARY OF dt,
len INTEGER 
#DEFINE arr2 DYNAMIC ARRAY OF dt


{LET item[1][1].order_num =10
DISPLAY item[1][1].order_num}      




 
DEFINE arr1 DYNAMIC ARRAY OF RECORD 
 order_num LIKE orders.order_num,
        item_desc LIKE stock.description,
        store_name LIKE customer.store_name,
        fac_name LIKE factory.fac_name,
        quantity LIKE items.quantity
    END RECORD
    
END GLOBALS 

## version 1 function start
FUNCTION version1()

 


### record to save a row of data
    DEFINE order_rep RECORD
        order_num LIKE orders.order_num,
        item_desc LIKE stock.description,
        store_name LIKE customer.store_name,
        fac_name LIKE factory.fac_name,
        quantity LIKE items.quantity
    END RECORD, i INT 

    ### this is how we append date with string
 DEFINE filename VARCHAR(100), dt DATETIME YEAR TO SECOND
 LET dt = CURRENT
 LET filename ="version 1 "||util.Datetime.format( CURRENT, "%Y-%m-%d-%H-%M" )||".txt"
 DISPLAY filename
    
   -- CONNECT TO "custdemo" USER "sa" USING "aman"
   
### cursor which contains all data and gives row  one by one 
    DECLARE cur CURSOR FOR
        SELECT orders.order_num,
            stock.description,
            customer.store_name,
            factory.fac_name,
            items.quantity
            FROM orders INNER JOIN items ON (orders.order_num = items.order_num)
                        INNER
                        JOIN customer
                        ON (orders.store_num = customer.store_num)
                    INNER
                    JOIN stock
                    ON (items.stock_num = stock.stock_num)
                INNER
                JOIN factory
                ON (orders.fac_code = factory.fac_code)

### report generation start
    START REPORT order_list
        TO FILE filename
            WITH LEFT MARGIN = 5, TOP MARGIN = 2, BOTTOM MARGIN = 2

        FOREACH cur INTO order_rep.*
            OUTPUT TO REPORT order_list(order_rep.*)
        END FOREACH

    FINISH REPORT order_list

    
### report generation end
CALL initialise()
 -- DISCONNECT CURRENT
CALL getdata()
{LET item["one"] = item_arr[1].*;
LET item["one"] = item_arr[2].*;}


DISPLAY item[2][1].stock_num
DISPLAY item[2][2].stock_num
DISPLAY item[2][3].stock_num


   -- DISCONNECT CURRENT
   
   
END FUNCTION 

FUNCTION initialise()
--CONNECT TO "custdemo" USER "sa" USING "aman"
DEFINE idx INTEGER ,ordno LIKE items.order_num
## for order array
   LET idx = 1
DECLARE curr_ord CURSOR FOR SELECT * FROM orders

    FOREACH curr_ord INTO  order_arr[idx].*
        LET idx = idx + 1
    END FOREACH
    ##delete last element
## for customer array
 LET idx = 1
DECLARE curr_customer CURSOR FOR SELECT * FROM customer

    FOREACH curr_customer INTO  customer_arr[idx].*
        LET idx = idx + 1
    END FOREACH

## for item array
 LET idx = 1
DECLARE curr_item CURSOR FOR SELECT * FROM items

    FOREACH curr_item INTO  item_arr[idx].*
 ### and here the mazic began 
  {LET item[1][1].order_num =10
DISPLAY item[1][1].order_num 
 
DEFINE var INTEGER 
 LET var = item[1].getLength()
 DISPLAY var}
#### here end 
        LET idx = idx + 1
    END FOREACH


    
## filling data into dictionary 'item' 
FOR idx =1 TO item_arr.getLength()
LET ordno = item_arr[idx].order_num
IF item.contains(ordno) THEN 
LET len = item[ordno].getLength()
LET item[ordno][len+1].* = item_arr[idx].*
ELSE
LET item[ordno][1].* = item_arr[idx].*
END IF 
END FOR
 




    
## for factory array
 LET idx = 1
DECLARE curr_factory CURSOR FOR SELECT * FROM factory

    FOREACH curr_factory INTO  factory_arr[idx].*
        LET idx = idx + 1
    END FOREACH

## for stock array
 LET idx = 1
DECLARE curr_stock CURSOR FOR SELECT * FROM stock

    FOREACH curr_stock INTO  stock_arr[idx].*
        LET idx = idx + 1
    END FOREACH


END FUNCTION 

FUNCTION getdata()

DEFINE i INT ,j INT ,idx INT =1 , 
order_num   LIKE orders.order_num,
store_num   LIKE orders.store_num,
fac_code    LIKE orders.fac_code,
fac_name    LIKE factory.fac_name,
description LIKE stock.description,
store_name  LIKE customer.store_name,
quantity    LIKE items.quantity,
stock_num   LIKE items.stock_num 


FOR i=1 TO order_arr.getLength()
 # from order array 
 LET order_num  = order_arr[i].order_num
 LET store_num  = order_arr[i].store_num
 LET fac_code   = order_arr[i].fac_code
{FOR j=1 TO item_arr.getLength()
IF order_num == item_arr[j].order_num
THEN
LET stock_num  = item_arr[j].stock_num --getstockno(item_arr[j].order_num)
LET description = getdescription(stock_num)
# suspect 
LET fac_name   = getfactoryname(fac_code)
LET store_name = getstorename(store_num)
LET quantity   = item_arr[j].quantity  --getquantity(order_num)

LET arr1[idx].fac_name   = fac_name
    LET arr1[idx].order_num  = order_num
    LET arr1[idx].store_name = store_name
    LET arr1[idx].item_desc  = description
    LET arr1[idx].quantity   = quantity
    LET idx = idx+1
 DISPLAY order_num||"   "||description||"   "||store_name||"   "||fac_name||"   "||quantity  
ELSE 
END IF

END FOR }

### retrieving data from dictionary
IF item.contains(order_num)
THEN
FOR j=1 TO item[order_num].getLength()
LET stock_num  = item[order_num][j].stock_num
LET description = getdescription(stock_num)
LET fac_name   = getfactoryname(fac_code)
LET store_name = getstorename(store_num)
LET quantity   = item[order_num][j].quantity 

LET arr1[idx].fac_name   = fac_name
    LET arr1[idx].order_num  = order_num
    LET arr1[idx].store_name = store_name
    LET arr1[idx].item_desc  = description
    LET arr1[idx].quantity   = quantity
    LET idx = idx+1
 DISPLAY order_num||"   "||description||"   "||store_name||"   "||fac_name||"   "||quantity 
END FOR  --j
 --getstockno(item_arr[j].order_num)

# suspect 



 
ELSE 
END IF
 
#####
   
END FOR --i

 
END FUNCTION 

FUNCTION getfactoryname(fac_code)
DEFINE fac_code LIKE orders.fac_code,
fac_name LIKE factory.fac_name, i INT 

 FOR i=1 TO factory_arr.getLength()
    IF factory_arr[i].fac_code == fac_code THEN 
     LET fac_name = factory_arr[i].fac_name;
    ELSE 
    END IF 
 END FOR 
 RETURN fac_name
END FUNCTION 

FUNCTION  getstorename(store_num)
DEFINE store_num LIKE customer.store_num, i INT,
store_name LIKE customer.store_name 

FOR i=1 TO customer_arr.getLength()
IF store_num == customer_arr[i].store_num
 THEN 
   LET store_name =customer_arr[i].store_name
ELSE 
END IF 
END FOR 

RETURN store_name

END FUNCTION 

FUNCTION getdescription(stock_num)
DEFINE stock_num LIKE stock.stock_num, i INT,
description LIKE stock.description
FOR i =1 TO stock_arr.getLength()
IF stock_arr[i].stock_num == stock_num 
THEN 
LET description = stock_arr[i].description
#RETURN description 
ELSE 
END IF 
END FOR

 RETURN description 

END FUNCTION 


FUNCTION getquantity(order_num)
DEFINE order_num LIKE items.order_num, i INT,
quantity LIKE items.quantity

FOR i=1 TO item_arr.getLength()
IF item_arr[i].order_num == order_num
THEN 
LET quantity = item_arr[i].quantity
ELSE  
END IF 
END FOR 

RETURN quantity 
END FUNCTION 

FUNCTION getstockno(order_num)
DEFINE order_num LIKE items.order_num, i INT, j INT, 
stock_num LIKE items.stock_num

FOR i=1 TO item_arr.getLength()

IF item_arr[i].order_num == order_num
THEN

LET stock_num = item_arr[i].stock_num ##
FOR j=1 TO stock_arr.getLength()
IF stock_arr[i].stock_num == stock_num 

THEN
IF stock_check[j]== false 
THEN 
LET stock_check[j] = true
RETURN stock_num 

ELSE
EXIT FOR  
END IF  
ELSE 
END IF 

END FOR 
#RETURN stock_num
ELSE 
END IF 
END FOR 
RETURN stock_num
END FUNCTION 