/* 
Devin Erickson
CIT325
Lab 4
*/

SPOOL Lab4.txt

        DECLARE
        
        TYPE day_name IS TABLE OF days;
        TYPE gift_name IS TABLE OF gifts;

        lv_day_name DAYS := days
                        ( dayofChristmas(1, 'first')
                        , dayofChristmas(2, 'second')
                        , dayofChristmas(3, 'third')
                        , dayofChristmas(4, 'fourth')
                        , dayofChristmas(5, 'fifth')
                        , dayofChristmas(6, 'sixth')
                        , dayofChristmas(7, 'seventh')
                        , dayofChristmas(8, 'eight')
                        , dayofChristmas(9, 'ninth')
                        , dayofChristmas(10, 'tenth')
                        , dayofChristmas(11, 'eleventh')
                        , dayofChristmas(12, 'twelfth'));
        lv_gift_name GIFT := gifts(
                          Gifts(1, 'Partridge in a pear tree')
                        , Gifts(2, 'Two, Turtle doves')
                        , Gifts(3, 'Three, French hens')
                        , Gifts(4, 'Four, Calling birds')
                        , Gifts(5, 'Five, Golden rings')
                        , Gifts(6, 'Six, Geese a laying')
                        , Gifts(7, 'Seven, Swans a swimming')
                        , Gifts(8, 'Eight, Maids a milking')
                        , Gifts(9, 'Nine, Ladies dancing')
                        , Gifts(10, 'Ten, Lords a leaping')
                        , Gifts(11, 'Eleven, Pipers piping')
                        , Gifts(12, 'Twelve, Drummers drumming'));

BEGIN 
        dbms_output.put_line(CHR(13));
        dbms_output.put_line('On the ' || lv_day_name(1).xtext || 'my true love gave to me, A ' || 
                lv_gift_name(1).xtext);
END;
/

SPOOL OFF
