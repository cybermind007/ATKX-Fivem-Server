let DroppedInventories = [];
let InUseInventories = [];
let DataEntries = 0;
let hasBrought = [];
let CheckedDeginv = [];
const DROPPED_ITEM_KEEP_ALIVE = 1000 * 60 * 15; 

function clean() {
    for (let Row in DroppedInventories) {
        if (new Date(DroppedInventories[Row].lastUpdated + DROPPED_ITEM_KEEP_ALIVE).getTime() < Date.now() && DroppedInventories[Row].used && !InUseInventories[DroppedInventories[Row].name]) {
               emitNet("Inventory-Dropped-Remove", -1, [DroppedInventories[Row].name])
               delete DroppedInventories[Row];
        }
    }
}

setInterval(clean, 20000)


function db(string) {
    exports.ghmattimysql.execute(string,{}, function(result) {
    });
}


RegisterServerEvent("server-remove-item")
onNet("server-remove-item", async (player,itemidsent,amount,openedInv) => {
    functionRemoveAny(player, itemidsent, amount, openedInv)
});

RegisterServerEvent("server-update-item")
onNet("server-update-item", async (player, itemidsent,slot,data) => {
    let src = source
    let playerinvname = player
    let string = `UPDATE user_inventory2 SET information='${data}' WHERE item_id='${itemidsent}' and name='${playerinvname}' and slot='${slot}'`

    exports.ghmattimysql.execute(string,{}, function() {
        emit("server-request-update-src",player,src)

    });
});

function functionRemoveAny(player, itemidsent, amount, openedInv) {
    let src = source
    let playerinvname = player
    let string = `DELETE FROM user_inventory2 WHERE name='${playerinvname}' and item_id='${itemidsent}' LIMIT ${amount}`

    exports.ghmattimysql.execute(string,{},function() {
        emit("server-request-update-src",player,src)
        emit('sendingItemstoClient', player,src)
    });
    
}

RegisterServerEvent("request-dropped-items")
onNet("request-dropped-items", async (player) => {
    let src = source;
    emitNet("requested-dropped-items", src, JSON.stringify(Object.assign({},DroppedInventories)));
});

RegisterServerEvent("server-request-update")
onNet("server-request-update", async (player) => {
    let src = source
    let playerinvname = player
    let string = `SELECT count(item_id) as amount, id, item_id, name, information, slot, quality, dropped FROM user_inventory2 WHERE name ='${player}' group by item_id`; 
    exports.ghmattimysql.execute(string, {}, function(inventory) {
    emitNet("inventory-update-player", src, [inventory,0,playerinvname]);

    });
});

RegisterServerEvent("server-request:update-src")
onNet("server-request-update-src", async (player,src) => {
    let playerinvname = player 
    let string = `SELECT count(item_id) as amount, item_id, id, name, information, slot, quality, dropped FROM user_inventory2 WHERE name = '${player}' group by item_id`; 
    exports.ghmattimysql.execute(string, {}, function(inventory) {
        emitNet("inventory-update-player", src, [inventory,0,playerinvname]);
    });
});

function makeid(length) {
    var result           = '';
    var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghikjlmnopqrstuvwxyz'; //abcdef
    var charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}



function GenerateInformation(player,itemid,itemdata) {
    let data = Object.assign({}, itemdata);
    let returnInfo = "{}"

    return new Promise((resolve, reject) => {
    if (itemid == "") return resolve(returninfo);
    let timeout = 0;
    if (!isNaN(itemid)) {
        var identifier = Math.floor((Math.random() * 99999) + 1)
        if(itemdata && itemdata.fakeWeaponData) {
            identifier = Math.floor((Math.random() * 99999) + 1)
            identifier = identifier.toString()
        }

        // should I remove that?
        let cartridgeCreated =  makeid(3) + "-" + Math.floor((Math.random() * 999) + 1);
        returnInfo = JSON.stringify({ cartridge: cartridgeCreated, serial: identifier})
        timeout = 1;
        clearTimeout(timeout)
        return resolve(returnInfo);
    } else if (Object.prototype.toString.call(itemid) ===  '[object String]') {
        switch(itemid.toLowerCase()) {
          case "idcard":
            console.log('ID CARD BE YEETING: ' + JSON.stringify(itemdata.fake))
          if(itemdata && itemdata.fake)
 {           console.log('ID CARD BE FAKE OR NOT CUH?: ' + JSON.stringify(itemdata.fake))
              returnInfo = JSON.stringify({
                  identifier: itemdata.charID,
                  Name: itemdata.first.replace(/[^\w\s]/gi, ''),
                  Surname: itemdata.last.replace(/[^\w\s]/gi, ''),
                  Sex: itemdata.sex,
                  DOB: itemdata.dob })
                  timeout = 1
                  clearTimeout(timeout)
                  console.log('yeet yeet potato ' + JSON.stringify(itemdata.fake))
                  return resolve(returnInfo);
              } else {
                let string = `SELECT firstname,lastname,sex,dateofbirth FROM users WHERE identifier = '${player}'`;
                        exports.ghmattimysql.execute(string,{}, function(result) {
                            returnInfo = JSON.stringify({
                                // cid: player.toString(),
                                Firstname: result[0].firstname.replace(/[^\w\s]/gi, ''),
                                Lastname: result[0].lastname.replace(/[^\w\s]/gi, ''),
                                Sex: result[0].sex,
                                DOB: result[0].dateofbirth })
                                timeout = 1
                                clearTimeout(timeout)
                                return resolve(returnInfo);
                            });
                    }
                    break;
                 case "casing":
                        returnInfo = JSON.stringify({ Identifier: itemdata.identifier, type: itemdata.eType, other: itemdata.other})
                        timeout = 1
                        clearTimeout(timeout)
                        return resolve(returnInfo);
                    case "evidence":
                        returnInfo = JSON.stringify({ Identifier:itemdata.identifier, type: itemdata.eType, other: itemdata.other })
                        timeout = 1;
                        clearTimeout(timeout)
                        return resolve(returnInfo);
                    case "drivingtest":
                         if (data.id) {
                            let string = `SELECT * FROM driving_tests WHERE id = '${data.id}'`;
                            exports.ghmattimysql.execute(string, {}, function(result) {
                                if (result[0]) {
                                    let ts = new Date(parseInt(result[0].timestamp) * 1000)
                                    let testDate = ts.getFullYear() + "-" + ("0"+(ts.getMonth()+1)).slice(-2) + "-" + ("0" + ts.getDate()).slice(-2)
                                    returninfo = JSON.stringify({ ID: result[0].id, CID: result[0].cid, Instructor: result[0].instructor, Date: testdata })
                                    timeout = 1;
                                    clearTimeout(timeout)
                                }
                                return resolve(returninfo);
                            });
                        } else {
                            timeout = 1;
                            clearTimeout(timeout)
                            return resolve(returnInfo);
                        }
                        break;
                    default:
                            timeout = 1
                            clearTimeout(timeout)
                            return resolve(returnInfo);
                        }
                    } else {
                        return resolve(returnInfo);
                    }

                    setTimeout(() => {
                        if (timeout == 0) {
                            return resolve(returnInfo);
                        }
                     },500)
            });
    }

    RegisterServerEvent("server-inventory-give")
    onNet("server-inventory-give", async (player, itemid, slot, amount, generateInformation, itemdata, openedInv) => {
        
        let src = source
        let playerinvname =  player
        let information = "{}"
        let creationDate = Date.now()
    
        if (itemid == "idcard") {
            information = await GenerateInformation(player,itemid,itemdata)
        }
          let values = `('${playerinvname}','${itemid}','${information}','${slot}','${creationDate}')`
             if (amount > 1) {
                 for (let i = 2; i <= amount; i++) {
                    values = values + `,('${playerinvname}','${itemid}','${information}','${slot}','${creationDate}')`
               
                }
            }
                     
        let query = `INSERT INTO user_inventory2 (name,item_id,information,slot,creationDate) VALUES ${values};`
        exports.ghmattimysql.execute(query,{},function() {
            emit("server-request-update-src",player,src)
            emit('sendingItemstoClient', player,src) // Stops actionbar from clearing when giving an item. - Kalxie
        });
    
    });

RegisterServerEvent("sendingItemstoClient")
onNet("sendingItemstoClient", async (player, sauce) => {
    let src = source
    if (!src) {
        src = sauce 
    }
    sendClientItemList(src)
    let string = `SELECT count(item_id) as amount, id, name, item_id, information, slot, dropped, quality, creationDate FROM user_inventory2 where name= '${player}' group by slot`;
    exports.ghmattimysql.execute(string,{}, function(inventory) {
        if (!inventory){}else{
        var invArray = inventory;
        var arrayCount = 0;
        var playerinvname = player
        emitNet("inventory-update-player", src, [invArray,arrayCount,playerinvname]);
        emitNet('current-items', src, invArray)
        }
    })
})

RegisterServerEvent("server-inventory-open")
onNet("server-inventory-open", async ( coords, player, secondInventory, targetName, itemToDropArray, sauce) => {

    let src = source

    if (!src) {
        src = sauce 
    }

    let playerinvname = player

    if ( InUseInventories[targetName] || InUseInventories[playerinvname] ) {
  
        if (InUseInventories[playerinvname]) {
            if ( ( InUseInventories[playerinvname] != player ) ) {
                return
            } else {
               
            }
        }
        if (InUseInventories[targetName]) {
            if (InUseInventories[targetName] == player) {

            } else {
                secondInventory = "69"
            }
        }
    }
    let string = `SELECT count(item_id) as amount, id, name, item_id, information, slot, dropped, quality, creationDate FROM user_inventory2 where name= '${player}' group by slot`;

    exports.ghmattimysql.execute(string,{}, function(inventory) {

        var invArray = inventory;
        var i;
        var arrayCount = 0;

           InUseInventories[playerinvname] = player;
 
           emitNet('current-items', src, invArray)
           
           if(secondInventory == "1") {
 
               var targetinvname = targetName
     
               let string = `SELECT count(item_id) as amount, id, name, item_id, information, slot, dropped, quality, creationDate FROM user_inventory2 WHERE name = '${targetinvname}' group by slot`;
               exports.ghmattimysql.execute(string,{}, function(inventory2) { 
                       emitNet("inventory-open-target", src, [invArray, arrayCount,playerinvname,inventory2,0,targetinvname,500,true]);
                  
                       InUseInventories[targetinvname] = player
               });
           }

           else if (secondInventory == "3") {
        
               let Key = ""+DataEntries+"";
               let NewDroppedName = 'Drop-' + Key;
    
               DataEntries = DataEntries + 1
               var invArrayTarget = [];
               DroppedInventories[NewDroppedName] = { position: { x: coords[0], y: coords[1], z: coords[2] }, name: NewDroppedName, used: false, lastUpdated: Date.now() }


               InUseInventories[NewDroppedName] = player;
       
               invArrayTarget = JSON.stringify(invArrayTarget)
               emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,invArrayTarget,0,NewDroppedName,500,false]);
               
}
else if (secondInventory == "13")
{   

    let Key = ""+DataEntries+"";
    let NewDroppedName = 'Drop-'  + Key;
    DataEntries = DataEntries + 1
      for (let Key in itemToDropArray) {
          for (let i = 0; i < itemToDropArray[Key].length; i++) {
              let objectToDrop = itemToDropArray[Key][i];
              db(`UPDATE user_inventory2 SET slot='${i+1}', name='${NewDroppedName}', dropped='1' WHERE name='${Key}' and slot='${objectToDrop.faultySlot}' and item_id='${objectToDrop.faultyItem}' `);
          
              emit('sendingItemstoClient', player,src)
           }
      }
       
      DroppedInventories[NewDroppedName] = { position: { x: coords[0], y: coords[1], z: coords[2] }, name: NewDroppedName, used: false, lastUpdated: Date.now() }
      emitNet("Inventory-Dropped-Addition", -1, DroppedInventories[NewDroppedName] )
    } else if(secondInventory == "2") {
                
        var targetinvname = targetName;
        var shopArray = ConvenienceStore();
        var shopAmount = 16;
        emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);

    }
    else if(secondInventory == "4")
{
    var targetinvname = targetName;
    var shopArray = HardwareStore();
    var shopAmount = 14;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
    else if(secondInventory == "5")
    {
        var targetinvname = targetName;
        var shopArray = GunStore();
        var shopAmount = 8;
        emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
    else if(secondInventory == "6") 
{
    var targetinvname = targetName;
    var shopArray = CraftRiflesStoreGang();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
    else if(secondInventory == "8")
{
    var targetinvname = targetName;
    var shopArray = CraftRiflesCivilians();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
    else if(secondInventory == "9")
{
    var targetinvname = targetName;
    var shopArray = GangStore();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}   
    else if(secondInventory == "10")
{
    var targetinvname = targetName;
    var shopArray = PoliceArmory();
    var shopAmount = 12;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}    
    else if(secondInventory == "12")
{
    var targetinvname = targetName;
    var shopArray = BurgieStore();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}    
   else if(secondInventory == "11")
{
    emitNet("inventory-open-target-NoInject", src, [invArray.arrayCount,playerinvname]);
}  else if(secondInventory == "14") {
    var targetinvname = targetName;
    var shopArray = CourtHouse();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}    
   else if(secondInventory == "15")
{
    var targetinvname = targetName;
    var shopArray = MedicArmory();
    var shopAmount = 7;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "29")
{
    var targetinvname = targetName;
    var shopArray = MedicArmoryCiv();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "16")
{
    var targetinvname = targetName;
    var shopArray = Workshop();
    var shopAmount = 2;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
else if(secondInventory == "17")
 {
     var targetinvname = targetName;
     var shopArray = Smelting();
     var shopAmount = 1;
     emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
 }  
   else if(secondInventory == "18")
{
    var targetinvname = targetName;
    var shopArray = TacoTruck();
    var shopAmount = 14;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "22")
{
    var targetinvname = targetName;
    var shopArray = JailFood();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "23")
{
    var targetinvname = targetName;
    var shopArray = JailCraft();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "24")
{
    var targetinvname = targetName;
    var shopArray = JailWeapon();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "25")
{
    var targetinvname = targetName;
    var shopArray = JailMeth();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  
   else if(secondInventory == "26")
{
    var targetinvname = targetName;
    var shopArray = JailPhone();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
   else if(secondInventory == "27")
{
    var targetinvname = targetName;
    var shopArray = JailSlushy();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
   else if(secondInventory == "28")
{
    var targetinvname = targetName;
    var shopArray = InmateLottery();
    var shopAmount = 7;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "31")
{
    var targetinvname = targetName;
    var shopArray = Blackmarket();
    var shopAmount = 13;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "55")
{
    var targetinvname = targetName;
    var shopArray = Mechanic();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "101")
{
    var targetinvname = targetName;
    var shopArray = PrisonShop();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "102")
{
    var targetinvname = targetName;
    var shopArray = ShankShop();
    var shopAmount = 1;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "103")
{
    var targetinvname = targetName;
    var shopArray = recycle();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}

else if(secondInventory == "104")
{
    var targetinvname = targetName;
    var shopArray = SmallGunCraft();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  


else if(secondInventory == "105")
{
    var targetinvname = targetName;
    var shopArray = IllgealCraft();
    var shopAmount = 5;
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}  

   else if(secondInventory == "7")
{
    var targetinvname = targetName;
    var shopArray = DroppedItem(itemToDropArray);
    
    itemToDropArray = JSON.parse(itemToDropArray)
    var shopAmount = itemToDropArray.length;
     
    emitNet("inventory-open-target", src, [invArray,arrayCount,playerinvname,shopArray,shopAmount,targetinvname,500,false]);
}
else {
    emitNet("inventory-update-player", src, [invArray,arrayCount,playerinvname]);
}
});
});

RegisterServerEvent("server-inventory-close")
onNet("server-inventory-close", async (player, targetInventoryName) => {
    let src = source
    if(targetInventoryName.startsWith("Trunk"))
    emitNet("toggle-animation", src, false);
    InUseInventories = InUseInventories.filter(item => item != player);
    if (targetInventoryName.indexOf("Drop") > -1 && DroppedInventories[targetInventoryName]) {
        if (DroppedInventories[targetInventoryName].used === false ) {
             delete DroppedInventories[targetInventoryName];
        } else {
            let string = `SELECT count(item_id) as amount, item_id, name, information, slot, quality, dropped FROM user_inventory2 WHERE name='${targetInventoryName}' group by item_id `;
            exports.ghmattimysql.execute(string,{}, function(result) {
                if (result.length == 0 && DroppedInventories[targetInventoryName]) {
                    delete DroppedInventories[targetInventoryName];
                    emitNet("Inventory-Dropped-Remove", -1, [targetInventoryName])
                    
                }
            });
        }
    }

});


let IllegalSearchString = `'weedoz', 'weed5oz', 'coke50g', 'thermite', 'weedq', 'weed12oz', 'oxy', '1gcrack', '1gcocaine', 'joint'`

RegisterServerEvent("inv:delete")
onNet("inv:delete", async (inv) => {
    db(`DELECT FROM user_inventory2 WHERE name='${inv}'`);
});


RegisterServerEvent("server-inventory-remove")
onNet("server-inventory-remove-slot", async (player, itemidsent,amount,slot) => {
    var playerinvname = player
    db(`DELETE FROM user_inventory2 WHERE name='${playerinvname}' and item_id='${itemidsent}' and slot='${slot}' LIMIT ${amount}`);
});

RegisterServerEvent("server-ragdoll-items") 
onNet("server-ragdoll-items", async (player) => {
     let currInventoryName = `${player}`
     let newInventoryName = `wait-${player}`
     db(`UPDATE user_inventory2 SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="mobilephone" `);
     db(`UPDATE user_inventory2 SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="idcard" `);
     await db(`DELETE FROM user_inventory2 WHERE name='${currInventoryName}'`);
    db(`UPDATE user_inventory2 SET name='${currInventoryName}', WHERE name='${newInventoryName}' and dropped=0`);
});


RegisterServerEvent('server-jail-item')
onNet("server-jail-item", async (player,isSentToJail) => {
    let currInventoryName = `${player}`
    let newInventoryName = `${player}`

    if(!isSentToJail) {
        currInventoryName = `${player}`
        newInventoryName = `jail-${player}`
    } else {
        currInventoryName = `jail-${player}`
        newInventoryName = `${player}`
    }

    db(`UPDATE user_inventory2 SET name='${currInventoryName}', WHERE name='${newInventoryName}' and dropped=0`);
});

function removecash(src,amount) {
    emit('cash:remove', src, amount)
}

setTimeout(CleanDroppedInventory, 5)

function sendClientItemList(src)
{
    emitNet('sendListAtOnce',src,itemList)
}


function DroppedItem(itemArray) {
    itemArray = JSON.parse(itemArray)
    var shopItems = [];

    shopItems[0] = { item_id: itemArray[0].itemid, id: 0, name: "shop", information: "{}", slot: 1, amount: itemArray[0].amount};

    return JSON.stringify(shopItems);
}
function BuildInventory(Inventory) {
    let buildInv = Inventory
    let invArray = {};
    for (let i = 0; i < buildInv.length; i++) {
        invArray[itemCount] = { item_id: buildInv[i].item_id, id: buildInv[i].id, name: buildInv[i].name, information: buildInv[i], slot: buildInv[i].slot};
        itemCount = itemCount + 1
    }
    return [JSON.stringify(invArray),itemCount]
}

function mathrandom(min, max) {
    return Math.floor(Math.random() * (max+1 - min) ) + min;
}


const DEGREDATION_INVENTORY_CHECK = 1000 * 60 * 60;
const DEGREDATION_TIME_BROKEN = 1000 * 60 * 40320;
const DEGREDATION_TIME_WORN = 1000 * 60 * 201000;



RegisterServerEvent("server-inventory-move")
onNet("server-inventory-move", async (player, data, coords) => {
    let targetslot = data[0]
    let startslot = data[1]
    let targetname = data[2].replace(/"/g, "");
    let startname = data[3].replace(/"/g, "");
    let purchase = data[4]
    let itemCosts = data[5]
    let itemidsent = data[6]
    let amount = data[7]
    let crafting = data[8]
    let isWeapon = data[9]
    let PlayerStore = data[10]
    let creationDate = Date.now()

    if ((targetname.indexOf("Drop") > -1 || targetname.indexOf("hidden") > -1) && DroppedInventories[targetname]) {

        if (DroppedInventories[targetname].used === false) {

            DroppedInventories[targetname] = { position: { x: coords[0], y: coords[1], z: coords[2]}, name: targetname, used: true, lastUpdated: Date.now() }
            emitNet("Inventory-Dropped-Addition", -1, DroppedInventories[targetname] )
        }
    }

    let info = "{}"

    if (purchase) {
        if(isWeapon) {


        }
        info = await GenerateInformation(player,itemidsent)
        removecash(source,itemCosts)

        if (!PlayerStore) {
            for (let i = 0; i < parseInt(amount); i++) {
        
                db(`INSERT INTO user_inventory2 (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);
            }
        } else if (PlayerStore) {
             payStore(startname,itemCosts,itemidsent)
           
                db(`INSERT INTO user_inventory2 (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);

            for (let i = 0; i < parseInt(amount); i++) {
                db(`UPDATE user_inventory2 SET slot='${targetslot}', name='${targetname}', dropped='0' WHERE slot='${startslot}' and name='${startname}'`);
 
            }
        } else if (crafting) {
     
            info - await GenerateInformation(player,itemidsent)
            for (let i = 0; i < parseInt(amount); i++) {
                db(`INSERT INTO user_inventory2 (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);
            }
        } else {
            if (targetname.indexOf("Drop") > -1 || targetname.indexOf("hidden") > -1) {

            db(`INSERT INTO user_inventory2 SET slot='${targetslot}', name='${targetname}', dropped='1' WHERE slot='${startslot}' AND name='${startname}'`);
            emit('sendingItemstoClient', player,src)
           } else {
            db(`UPDATE user_inventory2 SET slot='${targetslot}', name='${targetname}', dropped='0' WHERE slot='${startslot}' and name='${startname}'`);

           }
        }
     } else {

        if (crafting == true){

                     info - await GenerateInformation(player,itemidsent)
                    for (let i = 0; i < parseInt(amount); i++) {
                        db(`INSERT INTO user_inventory2 (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetname}','${info}','${targetslot}','${creationDate}' );`);
                    }
                }
           
            db(`UPDATE user_inventory2 SET slot='${targetslot}', name='${targetname}', dropped='0' WHERE slot='${startslot}' and name='${startname}'`);
     
    }
});

function CleanDroppedInventory() {
    onNet("server-ragdoll-items", async (player) => {
	    let currInventoryName = `${player}`	
        let newInventoryName = `wait-${player}`
   
        db(`UPDATE user_inventory2 SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="mobilephone" `);
        db(`UPDATE user_inventory2 SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="idcard" `);
   
       await db(`DELETE FROM user_inventory2 WHERE name='${currInventoryName}'`);
   
       db(`UPDATE user_inventory2 SET name='${currInventoryName}', WHERE name='${newInventoryName}' and dropped=0`);
    db(`DELETE FROM user_inventory2 WHERE dropped='1'`);
    db(`DELETE FROM user_inventory2 WHERE name='trash-1'`);
    db(`DELETE FROM user_inventory2 WHERE item_id IN ('foodingredient', 'coffee', 'fishtaco', 'taco', 'burrito', 'churro', 'hotdog', 'greencow', 'donut', 'eggsbacon', 'icecream', 'mshake')`)
     db(`UPDATE user_inventory2 SET name='${newInventoryName}', WHERE name='${currInventoryName}' and dropped=0 and item_id="bandage" `);
    })
};


RegisterServerEvent("server-inventory-stack")
onNet("server-inventory-stack", async (player, data, coords) => {
    ////console.log("getting here 1")
    let targetslot = data[0]
         let moveAmount = data[1]
    let targetName = data[2].replace(/"/g, "");
    let src = source
     let originSlot = data[3]

     let originInventory = data[4].replace(/"/g, "");

     let purchase = data[5]
     let itemCosts = data[6]
    let itemidsent = data[7]
     let amount = data[8]
     let crafting = data[9]
     let isWeapon = data[10]
     let PlayerStore = data[11]
     let amountRemaining = data[12]
     let creationDate = Date.now()
   //  ////print('icecream   ',crafting)
     ////console.log("getting here 2")
     ////console.log("getting here 33")

     if ( (targetName.indexOf("Drop") > -1 || targetName.indexOf("hidden") > -1) && DroppedInventories[targetName] ) {

         if (DroppedInventories[targetName].used === false ) {
             DroppedInventories[targetName] =  { position: { x: coords[0], y: coords[1], z: coords[2] }, name: targetName, used: true, lastUpdated: Date.now() }
             emitNet("Inventory-Dropped-Addition", -1, DroppedInventories[targetName] )
         }
     }

     let info = "{}"

     if (purchase) {

         if (isWeapon) {
            db(`INSERT INTO user_inventory2 (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetName}','${info}','${targetslot}','${creationDate}' );`);
            // hadBrought[player] = true
            // emitNet("inventory-brought-update", -,1 JSON.stringify(Object.assign({},hadBrought)))
         }
         info = await GenerateInformation(player,itemidsent)
         removecash(source,itemCosts)

         if (!PlayerStore) {
             for (let i = 0; i < parseInt(amount); i++) {

              db(`INSERT INTO user_inventory2 (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetName}','${info}','${targetslot}','${creationDate}' );`);
                 ////console.log(db)
                 ////console.log("INSERT user_inventory2 SET slot")

             }
         }
    

         if (PlayerStore) {
            let string = `SELECT id FROM user_inventory2 WHERE slot='${originSlot}' AND name='${originInventory}'`; //LIMIT ${moveAmount}
            payStore(originInventory,itemCosts,itemidsent)
            exports.ghmattimysql.execute(string,{}, function(startid) {

                var itemids = "0"
                for (let i = 0; i < startid.length; i++) {
                    itemids = itemids + "," + startid[i].id
                }
                db(`UPDATE user_inventory2 SET slot='${targetslot}', name='${targetname}', dropped='0' WHERE id IN (${itemids})`);
            });
         }


     } else if (crafting) {
        ////console.log('THIS IS CRAFTING XXXXXX')
         info = await GenerateInformation(player,itemidsent)
       //  ////print('craft here')
         for (let i = 0; i < parseInt(amount); i++) {

             db(`INSERT INTO user_inventory2 (item_id, name, information, slot, creationDate) VALUES ('${itemidsent}','${targetName}','${info}','${targetslot}','${creationDate}' );`);
         }
     } else {
         let string = `SELECT item_id, id FROM user_inventory2 WHERE slot='${originSlot}' and name='${originInventory}' LIMIT ${moveAmount}`;

         exports.ghmattimysql.execute(string,{}, function(result) {

            var itemids = "0"
            for (let i = 0; i < result.length; i++) {
                itemids = itemids + "," + result[i].id
            }
            
             if (targetName.indexOf("Drop") > -1 || targetName.indexOf("hidden") > -1) {
                ////console.log("UPDATE user_inventory2 SET slot 1")
                db(`UPDATE user_inventory2 SET slot='${targetslot}', name='${targetName}', dropped='1' WHERE id IN (${itemids})`);

             } else {
                 db(`UPDATE user_inventory2 SET slot='${targetslot}', name='${targetName}', dropped='0' WHERE id IN (${itemids})`);
                 ////console.log("UPDATE user_inventory2 SET slot 2", 'target:'+targetslot, 'targetName:'+targetName, 'OrigSlot:'+originSlot, 'OrigInv:'+originInventory, 'itemId:'+result[0].item_id, 'itemId:'+result[0].item_id)

             }
         });
     }
 });


RegisterServerEvent("server-inventory-swap")
onNet("server-inventory-swap", (player, data, coords) => {
     let targetslot = data[0]
     let targetname = data[1].replace(/"/g, "");
     let startslot = data[2]
     let startname = data[3].replace(/"/g, "");

     let string = `SELECT id FROM user_inventory2 WHERE slot='${targetslot}' AND name='${targetname}'`;
         
    exports.ghmattimysql.execute(string,{}, function(startid) {
        var itemids = "0"
        for (let i = 0; i < startid.length; i++) {
            itemids = itemids + "," + startid[i].id

        }

        let string = false;
        if (targetname.indexOf("Drop") > -1 || targetname.indexOf("hidden") > -1) {
            string = `UPDATE user_inventory2 SET slot='${targetslot}', name ='${targetname}', dropped='1' WHERE slot='${startslot}' AND name='${startname}'`;
        } else {
            string = `UPDATE user_inventory2 SET slot='${targetslot}', name ='${targetname}', dropped='0' WHERE slot='${startslot}' AND name='${startname}'`;
        }
 
        exports.ghmattimysql.execute(string,{}, function(inventory) {
            if (startname.indexOf("Drop") > -1 || startname.indexOf("hidden") > -1) {

                db(`UPDATE user_inventory2 SET slot='${startslot}', name='${startname}', dropped='0' WHERE id IN (${itemids})`);
            }
        });
    });
});

function PoliceArmory() {
    var shopItems = [
        { item_id: "-86904375", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
        { item_id: "-2084633992", id: 0, name: "Shop", information: "{}", slot: 2, amount: 1 },
        { item_id: "-771403250", id: 0, name: "Shop", information: "{}", slot: 3, amount: 1 },
        { item_id: "911657153", id: 0, name: "Shop", information: "{}", slot: 4, amount: 1 },
        { item_id: "1737195953", id: 0, name: "Shop", information: "{}", slot: 5, amount: 1 },
        { item_id: "2343591895", id: 0, name: "Shop", information: "{}", slot: 6, amount: 1 },
        { item_id: "pistolammo", id: 0, name: "Shop", information: "{}", slot: 7, amount: 5 },
        { item_id: "rifleammo", id: 0, name: "Shop", information: "{}", slot: 8, amount: 5 },
        { item_id: "armor", id: 0, name: "Shop", information: "{}", slot: 9, amount: 10 },
        { item_id: "watch", id: 0, name: "Shop", information: "{}", slot: 10, amount: 1 },
        { item_id: "IFAK", id: 0, name: "Shop", information: "{}", slot: 11, amount: 10 },
        { item_id: "radio", id: 0, name: "Shop", information: "{}", slot: 12, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function MedicArmory() {
    var shopItems = [
        { item_id: "armor", id: 0, name: "Shop", information: "{}", slot: 1, amount: 10 },  
        { item_id: "water", id: 0, name: "Shop", information: "{}", slot: 2, amount: 10 },
        { item_id: "radio", id: 0, name: "Shop", information: "{}", slot: 3, amount: 1 },  
        { item_id: "flowers", id: 0, name: "Shop", information: "{}", slot: 4, amount: 1 },  
        { item_id: "sandwich", id: 0, name: "Shop", information: "{}", slot: 5, amount: 10 },
        { item_id: "bandage", id: 0, name: "Shop", information: "{}", slot: 6, amount: 10 },  
        { item_id: "MedicalBag", id: 0, name: "Shop", information: "{}", slot: 7, amount: 5 },
    ];
    return JSON.stringify(shopItems);
}

function MedicArmoryCiv() {
    var shopItems = [
        { item_id: "armor", id: 0, name: "Shop", information: "{}", slot: 1, amount: 10 },  
        { item_id: "water", id: 0, name: "Shop", information: "{}", slot: 2, amount: 10 },  
        { item_id: "flowers", id: 0, name: "Shop", information: "{}", slot: 3, amount: 1 },  
        { item_id: "sandwich", id: 0, name: "Shop", information: "{}", slot: 4, amount: 10 },
        { item_id: "bandage", id: 0, name: "Shop", information: "{}", slot: 5, amount: 10 },    
    ];
    return JSON.stringify(shopItems);
}

function InMateLottery() {
    var shopItems = [
  
    ];
    return JSON.stringify(shopItems);
}

function JailFood() {
    var shopItems = [
        { item_id: "jailfood", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function Blackmarket() {
    var shopItems = [
        { item_id: "3523564046", id: 0, name: "craft", information: "{}", slot: 1, amount: 1 },
        { item_id: "584646201", id: 0, name: "craft", information: "{}", slot: 2, amount: 1 },
        { item_id: "-619010992", id: 0, name: "craft", information: "{}", slot: 3, amount: 1 },
        { item_id: "324215364", id: 0, name: "craft", information: "{}", slot: 4, amount: 1 },
        { item_id: "pistolammo", id: 0, name: "craft", information: "{}", slot: 5, amount: 5 },
        { item_id: "rifleammo", id: 0, name: "craft", information: "{}", slot: 6, amount: 5 },
        { item_id: "subammo", id: 0, name: "craft", information: "{}", slot: 7, amount: 5 },
        { item_id: "extended_ap", id: 0, name: "craft", information: "{}", slot: 8, amount: 1 },
        { item_id: "extended_micro", id: 0, name: "craft", information: "{}", slot: 9, amount: 1 },
        { item_id: "silencer_s", id: 0, name: "craft", information: "{}", slot: 10, amount: 1 },
        { item_id: "extended_tec9", id: 0, name: "craft", information: "{}", slot: 11, amount: 1 },
        
    ];
    return JSON.stringify(shopItems);
}


function TacoTruck() {
    var shopItems = [
          { item_id: "icecream", id: 0, name: "craft", information: "{}", slot: 1, amount: 1 },
          { item_id: "hotdog", id: 0, name: "craft", information: "{}", slot: 2, amount: 1 },
          { item_id: "water", id: 0, name: "craft", information: "{}", slot: 3, amount: 1 },
          { item_id: "greencow", id: 0, name: "craft", information: "{}", slot: 4, amount: 1 },
          { item_id: "donut", id: 0, name: "craft", information: "{}", slot: 5, amount: 1 },
          { item_id: "eggsbacon", id: 0, name: "craft", information: "{}", slot: 6, amount: 1 },
          { item_id: "hamburger", id: 0, name: "craft", information: "{}", slot: 7, amount: 1 },
          { item_id: "burrito", id: 0, name: "craft", information: "{}", slot: 8, amount: 1 },
          { item_id: "coffee", id: 0, name: "craft", information: "{}", slot: 9, amount: 1 },
          { item_id: "sandwich", id: 0, name: "craft", information: "{}", slot: 10, amount: 1 },
          { item_id: "fishtaco", id: 0, name: "craft", information: "{}", slot: 11, amount: 1 },
          { item_id: "mshake", id: 0, name: "craft", information: "{}", slot: 12, amount: 1 },
          { item_id: "taco", id: 0, name: "craft", information: "{}", slot: 13, amount: 1 },
          { item_id: "churro", id: 0, name: "craft", information: "{}", slot: 14, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function SmallGunCraft() {
    var shopItems = [
          { item_id: "-771403250", id: 0, name: "craft", information: "{}", slot: 1, amount: 1 },
          { item_id: "3218215474", id: 0, name: "craft", information: "{}", slot: 2, amount: 1 },
          { item_id: "584646201", id: 0, name: "craft", information: "{}", slot: 3, amount: 1 },
          { item_id: "137902532", id: 0, name: "craft", information: "{}", slot: 4, amount: 1 },
          { item_id: "324215364", id: 0, name: "craft", information: "{}", slot: 5, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function IllgealCraft() {
    var shopItems = [
          { item_id: "thermite", id: 0, name: "craft", information: "{}", slot: 1, amount: 50 },
          { item_id: "pistolammo", id: 0, name: "craft", information: "{}", slot: 2, amount: 50 },
          { item_id: "rasperry", id: 0, name: "craft", information: "{}", slot: 3, amount: 50 },
          { item_id: "c4_bank", id: 0, name: "craft", information: "{}", slot: 4, amount: 50 },
          { item_id: "unknown", id: 0, name: "craft", information: "{}", slot: 5, amount: 50 },
    ];
    return JSON.stringify(shopItems);
}

function JailWeapon() {
    var shopItems = [

    ];
    return JSON.stringify(shopItems);
}

function JailMeth() {
    var shopItems = [
        { item_id: "methbag", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function JailPhone() {
    var shopItems = [
    
    ];
    return JSON.stringify(shopItems);
}

function recycle() {
    var shopItems = [
          { item_id: "aluminium", id: 0, name: "craft", information: "{}", slot: 1, amount: 50 },
          { item_id: "plastic", id: 0, name: "craft", information: "{}", slot: 2, amount: 50 },
          { item_id: "rubber", id: 0, name: "craft", information: "{}", slot: 3, amount: 50 },
          { item_id: "scrapmetal", id: 0, name: "craft", information: "{}", slot: 4, amount: 50 },
          { item_id: "electronics", id: 0, name: "craft", information: "{}", slot: 5, amount: 50 },
          { item_id: "steel", id: 0, name: "craft", information: "{}", slot: 6, amount: 50 },
          { item_id: "glass", id: 0, name: "craft", information: "{}", slot: 7, amount: 50 },
    ];
    return JSON.stringify(shopItems);
}

function JailSlushy() {
    var shopItems = [
        { item_id: "slushy", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

 function Smelting() {
     var shopItems = [
        { item_id: "goldbar", id: 0, name: "craft", information: "{}", slot: 1, amount: 50 },
  
     ];
     return JSON.stringify(shopItems);
 }

function Mechanic() {
    var shopItems = [
        { item_id: "advrepairkit", id: 0, name: "craft", information: "{}", slot: 1, amount: 20 },
        { item_id: "repairkit", id: 0, name: "craft", information: "{}", slot: 2, amount: 20 },
        { item_id: "advlockpick", id: 0, name: "Shop", information: "{}", slot: 3, amount: 25 },
        { item_id: "lockpick", id: 0, name: "Shop", information: "{}", slot: 4, amount: 25 },
        { item_id: "nitrous", id: 0, name: "craft", information: "{}", slot: 5, amount: 5 },
        { item_id: "tuner", id: 0, name: "craft", information: "{}", slot: 6, amount: 1 },
    ];
    return JSON.stringify(shopItems);
}

function ConvenienceStore() {
    var shopItems = [
        { item_id: "sandwich", id: 0, name: "Shop", information: "{}", slot: 1, amount: 50 },
        { item_id: "hamburger", id: 0, name: "Shop", information: "{}", slot: 2, amount: 50 },
        { item_id: "cola", id: 0, name: "Shop", information: "{}", slot: 3, amount: 50 },
        { item_id: "water", id: 0, name: "Shop", information: "{}", slot: 4, amount: 50 },
        { item_id: "beer", id: 0, name: "Shop", information: "{}", slot: 5, amount: 50 },
        { item_id: "vodka", id: 0, name: "Shop", information: "{}", slot: 6, amount: 50 },
        { item_id: "whiskey", id: 0, name: "Shop", information: "{}", slot: 7, amount: 50 },
        { item_id: "bandage", id: 0, name: "Shop", information: "{}", slot: 8, amount: 50 },
        { item_id: "foodingredient", id: 0, name: "Shop", information: "{}", slot: 9, amount: 10 },
        { item_id: "ciggy", id: 0, name: "Shop", information: "{}", slot: 10, amount: 50 },
        { item_id: "mobilephone", id: 0, name: "Shop", information: "{}", slot: 11, amount: 50 },
        { item_id: "emptybaggies", id: 0, name: "Shop", information: "{}", slot: 12, amount: 50 },
        { item_id: "rollingpaper", id: 0, name: "Shop", information: "{}", slot: 13, amount: 50 },
        { item_id: "bakingsoda", id: 0, name: "Shop", information: "{}", slot: 14, amount: 50 },
        { item_id: "glucose", id: 0, name: "Shop", information: "{}", slot: 15, amount: 50 },
        { item_id: "cigar", id: 0, name: "Shop", information: "{}", slot: 16, amount: 50 },
    ];
    return JSON.stringify(shopItems);
}

function GangStore() {
    var shopItems = [
        { item_id: "whiskey", id: 0, name: "Shop", information: "{}", slot: 1, amount: 20 },
        { item_id: "redwine", id: 0, name: "Shop", information: "{}", slot: 2, amount: 20 },
   
    ];
    return JSON.stringify(shopItems);
}

function HardwareStore() {
    var shopItems = [
        { item_id: "repairkit", id: 0, name: "Shop", information: "{}", slot: 1, amount: 20 },
        { item_id: "oxygentank", id: 0, name: "Shop", information: "{}", slot: 2, amount: 20 },
        { item_id: "armor", id: 0, name: "Shop", information: "{}", slot: 3, amount: 20 },
        { item_id: "advlockpick", id: 0, name: "Shop", information: "{}", slot: 4, amount: 20 },
        { item_id: "radio", id: 0, name: "Shop", information: "{}", slot: 5, amount: 20 },
        { item_id: "watch", id: 0, name: "Shop", information: "{}", slot: 6, amount: 20 },
        { item_id: "Suitcase", id: 0, name: "Shop", information: "{}", slot: 7, amount: 20 },
        { item_id: "plantpot", id: 0, name: "Shop", information: "{}", slot: 8, amount: 20 },
        { item_id: "highgradefert", id: 0, name: "Shop", information: "{}", slot: 9, amount: 20 },
        { item_id: "highgrademaleseed", id: 0, name: "Shop", information: "{}", slot: 10, amount: 20 },
        { item_id: "purifiedwater", id: 0, name: "Shop", information: "{}", slot: 11, amount: 20 },
        { item_id: "lockpick", id: 0, name: "Shop", information: "{}", slot: 12, amount: 20 },
        { item_id: "fishingrod", id: 0, name: "Shop", information: "{}", slot: 13, amount: 20 },
        { item_id: "tuner", id: 0, name: "Shop", information: "{}", slot: 14, amount: 1 },
   
    ];
    return JSON.stringify(shopItems);
}

function GunStore() {
    var shopItems = [
        { item_id: "453432689", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
        { item_id: "pistolammo", id: 0, name: "Shop", information: "{}", slot: 2, amount: 5 },
        { item_id: "3441901897", id: 0, name: "Shop", information: "{}", slot: 3, amount: 1 },
        { item_id: "1593441988", id: 0, name: "Shop", information: "{}", slot: 4, amount: 1 },
        { item_id: "2508868239", id: 0, name: "Shop", information: "{}", slot: 5, amount: 1 },
        { item_id: "911657153", id: 0, name: "Shop", information: "{}", slot: 6, amount: 1 },
        { item_id: "2343591895", id: 0, name: "Shop", information: "{}", slot: 7, amount: 1 },
        { item_id: "2227010557", id: 0, name: "Shop", information: "{}", slot: 8, amount: 1 },
    ];
    return JSON.stringify(shopItems);
};

function BurgieStore() {
    var shopItems = [
        { item_id: "hamburger", id: 0, name: "Shop", information: "{}", slot: 1, amount: 5 },
        { item_id: "heartstopper", id: 0, name: "Shop", information: "{}", slot: 2, amount: 5 },
        { item_id: "moneyshot", id: 0, name: "Shop", information: "{}", slot: 3, amount: 5 },
        { item_id: "meatfree", id: 0, name: "Shop", information: "{}", slot: 4, amount: 5 },
        { item_id: "mshake", id: 0, name: "Shop", information: "{}", slot: 5, amount: 5 },
    ];
    return JSON.stringify(shopItems);
};

function PrisonShop() {
    var shopItems = [
        { item_id: "lockpick", id: 0, name: "Shop", information: "{}", slot: 1, amount: 3 },
    ];
    return JSON.stringify(shopItems);
};

function ShankShop() {
    var shopItems = [
        { item_id: "-538741184", id: 0, name: "Shop", information: "{}", slot: 1, amount: 1 },
    ];
    return JSON.stringify(shopItems);
};

onNet('onResourceStop', (resource) => {
    if (resource == GetCurrentResourceName()){
     db(`DELETE FROM user_inventory2 WHERE name like '%Drop%' OR name like '%Hidden%'`)
    }
})