# flutter_midtrans_cc

Midtrans Credit Card With 3DS handler for Flutter

## Initialize midtrans
```
FlutterMidtransCC midtransCC;

@override
initState(){
    midtransCC = FlutterMidtransCC(
        'midtrans_production_url',
        'midtrans_staging_url', 
        'server_key', 
        'client_key',
        isProduction: false,
    );
    super.initState();
}
```

## Get CC Token
```
midtransCC.getCreditCardToken("Credit card number", "Expiry Date",
                      "Expiry year", "cvv");
```

## Charge payment and redirect to 3DS
```
 midtransCC.midtransCharge("token id", 'custom item id', 'item price', item_details, customer_details);
```

see example for more detailed usage

### Notes: you need to activate Midtrans Web SDK before using this package