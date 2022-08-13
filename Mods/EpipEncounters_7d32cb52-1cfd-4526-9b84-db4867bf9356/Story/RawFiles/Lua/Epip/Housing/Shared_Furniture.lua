
local Housing = Epip.GetFeature("EpipEncounters", "Housing") ---@type Feature_Housing

---@type Feature_Housing_Furniture[]
local funiture = {
    {
        Name = "Simple Table",
        TemplateGUID = "54dd6743-652d-43a6-a0da-1fe830c748f6",
        Type = "Table",
    },
    {
        Name = "Bonfire",
        TemplateGUID = "130692f2-a065-4168-be66-27cf4df2fff0",
        Type = "Light",
    },
    {
        Name = "Sack",
        TemplateGUID = "9cd8dce2-a876-4c82-93e2-80405df6b3dd",
        Type = "Container",
    },
    {
        Name = "Well",
        TemplateGUID = "4a68c2d2-7f84-4547-87e5-1b34763be80d",
        Type = "Facility",
    },
    {
        Name = "Wall Torch",
        TemplateGUID = "d5e434cf-3aed-4110-a0e4-60912f855cb9",
        Type = "Light",
    },
    {
        Name = "Target",
        TemplateGUID = "4ea5d2e7-9eef-4fa6-b499-def0bec1dd0e",
        Type = "Facility",
    },
    {
        Name = "Coffe Table",
        TemplateGUID = "40c14ba8-7db1-4337-ba56-36b1a310b305",
        Type = "Table",
    },
    {
        Name = "Training Dummy",
        TemplateGUID = "24a466e5-9f0c-41f6-b4dd-74443858cead",
        Type = "Facility",
    },
    {
        Name = "Brazier",
        TemplateGUID = "89801429-59d5-4846-a5f4-c8f79d77ee5f",
        Type = "Light",
    },
    {
        Name = "Bedroll",
        TemplateGUID = "eae64571-4e99-4036-b3e2-1dcc6da78c89",
        Type = "Bed",
    },
    {
        Name = "Barrel",
        TemplateGUID = "a2b18299-6ee5-48fe-a34b-4e212eb405a7",
        Type = "Container",
    },
    {
        Name = "Reinforced Crate",
        TemplateGUID = "71b52721-a4d7-4eee-8ce8-fe5f1f5bddb4",
        Type = "Container",
    },
    {
        Name = "Crude Bench",
        TemplateGUID = "a350c92c-8af2-45f3-9610-d889b1d72231",
        Type = "Chair",
    },
    {
        Name = "Short Ladder",
        TemplateGUID = "a058fa9c-74c9-4eb2-baa0-a182a766a5fc",
        Type = "Facility",
    },
    {
        Name = "Sack Pile",
        TemplateGUID = "1ed7a061-5535-4958-87e8-cdffe2bf2dcd",
        Type = "Container",
    },
    {
        Name = "Stool",
        TemplateGUID = "e20c2413-ee40-4dee-9eca-3bf0863e13d5",
        Type = "Chair",
    },
    {
        Name = "Pew",
        TemplateGUID = "49f624e6-d7c5-4ffc-8468-788b7cf06824",
        Type = "Chair",
    },
    {
        Name = "Globe",
        TemplateGUID = "da3682f8-38d7-4d67-b245-352833491ef8",
        Type = "Trinket",
    },
    {
        Name = "Simple Chair",
        TemplateGUID = "956438cd-7114-4e92-bbcb-85486c20de30",
        Type = "Chair",
    },
    {
        Name = "Painting of Alexandar",
        TemplateGUID = "2ac8eff3-c582-499b-97ac-e605fd0f0396",
        Type = "Painting",
    },
    {
        Name = "Dressing Panel",
        TemplateGUID = "cf8797ec-8f01-42b7-8821-79ecdf3d2682",
        Type = "Decor",
    },
    {
        Name = "Candles",
        TemplateGUID = "728b84a6-3929-48eb-9368-631a0614e38d",
        Type = "Light",
    },
    {
        Name = "Aeve Van Algaris",
        TemplateGUID = "196baf1d-0d1c-4214-8e8e-61631450821b",
        Type = "Painting",
    },
    {
        Name = "Jail Door",
        TemplateGUID = "358ed990-5cbe-4972-a55e-901219f044d3",
        Type = "Door",
    },
    {
        Name = "Standing Torch",
        TemplateGUID = "02e4b0a4-b2de-4470-846e-1d76be4a0751",
        Type = "Light",
    },
    {
        Name = "Danrun",
        TemplateGUID = "1dcbc71a-15b6-49c8-97b5-10992e50917f",
        Type = "Painting",
    },
    {
        Name = "Rolled Up Carpet",
        TemplateGUID = "37157bc2-2f63-4c28-8bc3-8bec90cb3003",
        Type = "Clutter",
    },
    {
        Name = "Rope",
        TemplateGUID = "12236881-db9f-4086-9f42-b4c729ef593f",
        Type = "Clutter",
    },
    {
        Name = "Tool Rack",
        TemplateGUID = "ac016da7-9947-4253-908d-6661fec476d8",
        Type = "Hangable",
    },
    {
        Name = "Old Plate",
        TemplateGUID = "ed957a87-f07a-4d22-94b8-116e2781c174",
        Type = "Trinket",
    },
    {
        Name = "Open Sack",
        TemplateGUID = "ca5bdf35-1bbc-42b1-bfa8-29f07ef91841",
        Type = "Container",
    },
    {
        Name = "Reinforced Barrel",
        TemplateGUID = "820f165e-62f5-4de4-a739-6274cfac1c8e",
        Type = "Container",
    },
    {
        Name = "Sign Post",
        TemplateGUID = "b775b6c8-a349-4c30-831b-55ada69510b1",
        Type = "Other",
    },
    {
        Name = "Lamp Post",
        TemplateGUID = "b9624923-d8ca-45da-82a1-6839bf8d1e5b",
        Type = "Light",
    },
    {
        Name = "? Statue",
        TemplateGUID = "084d307e-2929-45db-a6f2-6d14c62e1172",
        Type = "Statue",
    },
    {
        Name = "Tree Stump",
        TemplateGUID = "86835e6e-a56d-42fe-b876-037f37280a01",
        Type = "Container",
    },
    {
        Name = "Small Haystack",
        TemplateGUID = "e91ff533-39d6-4990-ae3f-f392f85eb7f4",
        Type = "Other",
    },
    {
        Name = "Haystack",
        TemplateGUID = "dd532b69-d6d7-4514-9b64-7e5c9165dfcd",
        Type = "Other",
    },
    {
        Name = "Ornate Chest",
        TemplateGUID = "4d4af4a3-5916-4b83-b2c4-d6bc454544ed",
        Type = "Container",
    },
    {
        Name = "Oil Barrel",
        TemplateGUID = "1b34b32c-e96c-404e-90cc-054cb549c558",
        Type = "Facility",
    },
    {
        Name = "Bench",
        TemplateGUID = "efa6d1fb-2d03-4aff-a654-382d751e0029",
        Type = "Chair",
    },
    {
        Name = "Tall Vase",
        TemplateGUID = "ce4583ad-e3af-4fca-9379-e52fe1781a0c",
        Type = "Container",
    },
    {
        Name = "Water Barrel",
        TemplateGUID = "59b25792-1cc2-4364-92eb-89aca8fb8425",
        Type = "Facility",
    },
    {
        Name = "Campfire",
        TemplateGUID = "6fee7bbb-4adc-4222-a5b1-82fcfb8d1230",
        Type = "Light",
    },
    {
        Name = "Ceramic Jug",
        TemplateGUID = "cd69c666-426c-4e6b-9cf4-b55777d73d2f",
        Type = "Trinket",
    },
    {
        Name = "Tall Broken Vase",
        TemplateGUID = "2431067a-9db0-4205-ba10-c92d69c437be",
        Type = "Clutter",
    },
    {
        Name = "Fat Vase",
        TemplateGUID = "0c376265-255f-4cff-9311-6223d2a2ec73",
        Type = "Container",
    },
    {
        Name = "Vase",
        TemplateGUID = "c101e371-fb93-41e1-ac9b-fde41e85d76e",
        Type = "Container",
    },
    {
        Name = "Cooking Pot",
        TemplateGUID = "792f35b4-e700-434d-8feb-a1af3f35a034",
        Type = "Facility",
    },
    {
        Name = "Flower Pot",
        TemplateGUID = "ae32612f-ee16-444a-aece-a8cb35aac086",
        Type = "Decor",
    },
    {
        Name = "Tall Candles",
        TemplateGUID = "ef4d1dd9-8d2a-4677-98c3-bb9dd52c0865",
        Type = "Light",
    },
    {
        Name = "Anvil",
        TemplateGUID = "4fcd8129-ad8c-46ff-9373-329387e5b214",
        Type = "Facility",
    },
    {
        Name = "Basket",
        TemplateGUID = "024f59ea-3f37-4e93-b7d9-54f18b5e7541",
        Type = "Decor",
    },
    {
        Name = "Fishing Rod",
        TemplateGUID = "90cdb693-3564-415a-a8fa-4027b7f76f41",
        Type = "Item",
    },
    {
        Name = "Fish Rack",
        TemplateGUID = "307af24b-734a-445b-9325-7d55944e87cd",
        Type = "Container",
    },
    {
        Name = "Open Pot",
        TemplateGUID = "bd240774-79d9-4dd2-ad4f-ccc0660c7731",
        Type = "Clutter",
    },
    {
        Name = "Pot Lid",
        TemplateGUID = "c53675dc-ffc3-43a8-b829-220d01404840",
        Type = "Clutter",
    },
    {
        Name = "Small Pot",
        TemplateGUID = "f2774e19-7970-4eda-b423-28d6d75c4629",
        Type = "Clutter",
    },
    {
        Name = "Crude Torch",
        TemplateGUID = "d0a03afd-059b-41e5-9446-7c6540270305",
        Type = "Light",
    },
    {
        Name = "Wooden Box",
        TemplateGUID = "6f65dd10-5703-4a44-9c76-2577fd9f9366",
        Type = "Table",
    },
    {
        Name = "Well-Worn Chest",
        TemplateGUID = "db7066f9-3dc5-47b3-a318-dbbc3a0fdace",
        Type = "Container",
    },
    {
        Name = "Crude Ladder",
        TemplateGUID = "93304308-825a-419d-b66a-6a91ce987727",
        Type = "Facility",
    },
    {
        Name = "Bowl",
        TemplateGUID = "aeb79511-a929-43b4-9734-7e62da001c2b",
        Type = "Clutter",
    },
    {
        Name = "Skull Candle",
        TemplateGUID = "8c255787-ee37-447a-a25d-c3d5fcb52a64",
        Type = "Light",
    },
    {
        Name = "Fancy Candle",
        TemplateGUID = "f21393ff-31bc-46ff-a024-985e72cd83f5",
        Type = "Light",
    },
    {
        Name = "Candelabra",
        TemplateGUID = "e1a4cbd6-7508-4fa2-810b-ac15e0d84ae2",
        Type = "Light",
    },
    {
        Name = "Lever",
        TemplateGUID = "c42768fb-ee31-459c-b0c3-1c92efaf0304",
        Type = "Interactable",
    },
    {
        Name = "Small Brazier",
        TemplateGUID = "2b3a494e-a257-4ca0-b1f6-86c7ab75f493",
        Type = "Light",
    },
    {
        Name = "Huge Door",
        TemplateGUID = "d1617e38-b9d1-4222-b7ba-58d83a8d4180",
        Type = "Door",
    },
    {
        Name = "Dog Cage Door",
        TemplateGUID = "98cb6feb-c5eb-40cb-a966-4951f7ab40b0",
        Type = "Door",
    },
    {
        Name = "Wardrove",
        TemplateGUID = "05351551-19de-45bc-b593-15b42dee409a",
        Type = "Container",
    },
    {
        Name = "Desk",
        TemplateGUID = "d1dc717d-2744-4fb3-8925-61c3916df880",
        Type = "Container",
    },
    {
        Name = "Screen",
        TemplateGUID = "8f9fde4e-e85a-4785-b003-aecea3fb6593",
        Type = "Decor",
    },
    {
        Name = "Blue Bed",
        TemplateGUID = "0b9bea17-d270-415b-aa05-963e44b7c381",
        Type = "Bed",
    },
    {
        Name = "Dresser",
        TemplateGUID = "f4e21a23-2f75-478b-b13a-fae102f506d7",
        Type = "Container",
    },
    {
        Name = "Empty Cup",
        TemplateGUID = "bb6e5fbd-6adc-406b-978a-214a8c178cbb",
        Type = "Clutter",
    },
    {
        Name = "That thing where you put your silverware",
        TemplateGUID = "15f6b829-8f6c-4132-bce9-8b9a5bbcfe9c",
        Type = "Container",
    },
    {
        Name = "Torture Bed A",
        TemplateGUID = "578db52c-d993-4098-98ff-b51a372374e1",
        Type = "Bed",
    },
    {
        Name = "Torture Bed B",
        TemplateGUID = "08415b20-279f-4c24-89ec-de16c503e528",
        Type = "Bed",
    },
    {
        Name = "Torture Bed C",
        TemplateGUID = "00549009-f9f3-462a-bc8f-a3922eca6a55",
        Type = "Bed",
    },
    {
        Name = "Coffin",
        TemplateGUID = "480f023e-8f64-4b56-b411-c634a2e901d1",
        Type = "Container",
    },
    {
        Name = "Lady Mariette Karr",
        TemplateGUID = "1a504751-a68e-4ba9-8f2c-9cc7d7ec5a0a",
        Type = "Painting",
    },
    {
        Name = "Row of Books",
        TemplateGUID = "0e2ab200-6748-416a-9b76-c350a98f1dea",
        Type = "Container",
    },
    {
        Name = "Package",
        TemplateGUID = "0744e746-b390-41fa-be0b-063125997724",
        Type = "Clutter",
    },
    {
        Name = "Shop Sign",
        TemplateGUID = "52647714-3d17-40f8-92bb-03c0dd6888bd",
        Type = "Other",
    },
    {
        Name = "Tavern Sign",
        TemplateGUID = "1ab4a60d-14c2-4f77-884b-ed278e8c790b",
        Type = "Hangable",
    },
    {
        Name = "Huge Keg",
        TemplateGUID = "577e1099-5519-438c-baf2-3c8537dcdf8a",
        Type = "Facility",
    },
    {
        Name = "Bee Hive",
        TemplateGUID = "c46a033a-c2fb-4a6a-8d14-550617bdde0b",
        Type = "Facility",
    },
    {
        Name = "Simple Chest",
        TemplateGUID = "219f6175-312b-4520-afce-a92c7fadc1ee",
        Type = "Container",
    },
    {
        Name = "Broom",
        TemplateGUID = "0291fc01-b613-4f68-90f6-9263537cb680",
        Type = "Item",
    },
    {
        Name = "Skull Pile",
        TemplateGUID = "6ff0235e-7d72-46a4-a0c4-680b070f7ca7",
        Type = "Container",
    },
    {
        Name = "This needs a name",
        TemplateGUID = "b9e5064f-114b-4acb-89a1-787710e3d601",
        Type = "Other",
    },
    {
        Name = "Mug of Beer",
        TemplateGUID = "2cda275d-2aea-4e57-970a-0cdb9c342b86",
        Type = "Item",
    },
    {
        Name = "Bottle of Beer",
        TemplateGUID = "db0fab18-da5b-402c-8680-13a18163e7f8",
        Type = "Item",
    },
    {
        Name = "Celeste Sorensen",
        TemplateGUID = "3b94baae-f7bc-49c0-9f84-594a1b095953",
        Type = "Painting",
    },
    {
        Name = "Drudanae Pipe",
        TemplateGUID = "c73346fb-d95c-460a-b417-1014dfc0450f",
        Type = "Facility",
    },
    {
        Name = "Luxurious Couch",
        TemplateGUID = "2e8d5dc8-c1b1-4801-9682-5d118ade3e87",
        Type = "Chair",
    },
    {
        Name = "Drudanae",
        TemplateGUID = "84ce1dfa-12b1-4b37-8907-aa7301f1edbf",
        Type = "Item",
    },
    {
        Name = "Ooze Barrel",
        TemplateGUID = "0ae0668f-418c-46c4-bcbb-1683aa3c68e3",
        Type = "Facility",
    },
    {
        Name = "Wooden Stairs",
        TemplateGUID = "fa26a058-89bf-4bed-8d88-e837c789daec",
        Type = "Other",
    },
    {
        Name = "Erlend the Annihilator",
        TemplateGUID = "ff14c86e-c9d6-4036-85e8-6e1bc40cb99a",
        Type = "Painting",
    },
    {
        Name = "Deck of Cards",
        TemplateGUID = "4ecaa693-a6b4-4513-898a-411f0140d63b",
        Type = "Item",
    },
    {
        Name = "Painting of a Landscape",
        TemplateGUID = "2f3200c5-549a-4234-ba0e-df1edc957bf9",
        Type = "Painting",
    },
    {
        Name = "Augmentor",
        TemplateGUID = "8d6649d0-4cfa-45ad-b72c-9d69adecbfad",
        Type = "Item",
    },
    {
        Name = "Pretty Vase",
        TemplateGUID = "50a5f36d-9cef-4170-88a8-d2401ff612c0",
        Type = "Container",
    },
    {
        Name = "Painting of Rhalic",
        TemplateGUID = "5feca39b-0c77-4900-9bf8-aa516a7cc76f",
        Type = "Painting",
    },
    {
        Name = "Painting of Tir-Cendelius",
        TemplateGUID = "d9aa7ac2-9bef-49db-b240-ee39ccf41354",
        Type = "Painting",
    },
    {
        Name = "Painting of Zorl-Stissa",
        TemplateGUID = "07b4c753-6497-4745-bb2f-19e51335b58b",
        Type = "Painting",
    },
    {
        Name = "Painting of Xantezza",
        TemplateGUID = "aa387299-b2e7-4ef9-94d4-bfa9dc2ca2df",
        Type = "Painting",
    },
    {
        Name = "Painting of Vrogir",
        TemplateGUID = "10405397-a460-4a8c-9c61-da14c6d4d7af",
        Type = "Painting",
    },
    {
        Name = "Painting of Duna",
        TemplateGUID = "340f725e-a772-47de-8060-8f3d0178bbb4",
        Type = "Painting",
    },
    {
        Name = "Painting of Amadia",
        TemplateGUID = "67dda7b7-48ca-4267-855d-bcd013f29743",
        Type = "Painting",
    },
    {
        Name = "Luxurious Bed",
        TemplateGUID = "91234338-5735-461f-ab5e-2c820cd178d2",
        Type = "Bed",
    },
    {
        Name = "Bowl",
        TemplateGUID = "44e69605-e718-491a-9cd6-f9d16c139d6d",
        Type = "Item",
    },
    {
        Name = "Wardrobe",
        TemplateGUID = "a1d78c6a-9fcd-4583-afac-3af10b3f18d7",
        Type = "Container",
    },
    {
        Name = "Yellow Flower Pot",
        TemplateGUID = "10974d63-f41c-42a6-8e4a-56256e28ea09",
        Type = "Decor",
    },
    {
        Name = "Stardust Herb",
        TemplateGUID = "21943084-4c5d-46cc-a2bf-0fd9859319c1",
        Type = "Item",
    },
    {
        Name = "Green Flower Vase",
        TemplateGUID = "cba10ad1-68ca-4be3-a7eb-f7ef8a0066e7",
        Type = "Decor",
    }
    -- {
    --     Name = "",
    --     TemplateGUID = "",
    --     Type
    -- },
}
for _,data in ipairs(funiture) do
    Housing.RegisterFurniture(data)
end