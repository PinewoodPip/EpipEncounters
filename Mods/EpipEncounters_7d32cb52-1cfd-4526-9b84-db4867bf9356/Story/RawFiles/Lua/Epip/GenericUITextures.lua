
---------------------------------------------
-- Holds references to UI textures in Epip, intended to be used in Generic.
---------------------------------------------

local T = Texture.RegisterTexture

---@class Feature_GenericUITextures : Feature
local Textures = {
    TEXTURES = {
        BACKGROUNDS = {
            PAGE = T("PIP_UI_Background_Page", {
                GUID = "870ec5be-2599-4996-bc8e-438ba1eb8b4a",
            }),
        },
        BUTTONS = {
            ARROWS = {
                DOWN = {
                    IDLE = T("PIP_UI_Button_Arrow_Down_Idle", {
                        GUID = "baf044c7-d213-4ae7-977a-29710e7eba8e",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Arrow_Down_Highlighted", {
                        GUID = "71629c68-5899-462e-9edd-91864d6cdb52",
                    }),
                    PRESSED = T("PIP_UI_Button_Arrow_Down_Pressed", {
                        GUID = "27a0910a-71f3-4902-96c4-13b734a7a578",
                    }),
                },
                UP = {
                    IDLE = T("PIP_UI_Button_Up_Idle", {
                        GUID = "14385217-cb4b-4e9d-ad52-aa514f5a5cf4",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Up_Highlighted", {
                        GUID = "db8c0f50-411b-4ad4-96db-00c7a286933e",
                    }),
                    PRESSED = T("PIP_UI_Button_Up_Pressed", {
                        GUID = "872205af-df11-4fad-84e3-d96e6af3eeca",
                    }),
                },
                DIAMOND = {
                    DOWN = {
                        IDLE = T("PIP_UI_Button_Diamond_Down_Idle", {
                            GUID = "9cf5e7f5-8729-4388-9eb3-72d016a6a689",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Diamond_Down_Highlighted", {
                            GUID = "7c0c1a73-7cc3-4649-8678-427fc907fc63",
                        }),
                    },
                    NORMAL = {
                        IDLE = T("PIP_UI_Button_Diamond_Idle", {
                            GUID = "52057ae6-2938-4af6-83c2-bf84d1eeb8bd",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Diamond_Highlighted", {
                            GUID = "93d4308e-f238-41d5-80b7-30cadbeb57bb",
                        }),
                    },
                    UP = {
                        IDLE = T("PIP_UI_Button_Diamond_Up_Idle", {
                            GUID = "efbfcc12-b9bc-4a0b-9e25-f215aa0d0982",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Diamond_Up_Highlighted", {
                            GUID = "0c7cbe9d-161a-458f-9fb6-e0686c42b0e3",
                        }),
                    },
                    DOUBLE = {
                        IDLE = T("PIP_UI_Button_DoubleDiamond_Idle", {
                            GUID = "8be86e73-da60-4d71-9631-30b175932501",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_DoubleDiamond_Highlighted", {
                            GUID = "801eae78-6f28-46c5-b3a6-671ec44ce248",
                        }),
                    },
                },
                SQUARE = {
                    UP = {
                        IDLE = T("PIP_UI_Button_SquareUp_Idle", {
                            GUID = "98d345dd-cc12-427b-bbcb-de7d33f95824",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_SquareUp_Highlighted", {
                            GUID = "f0b36792-1671-496e-ab97-5f9e5cdd19f0",
                        }),
                        PRESSED = T("PIP_UI_Button_SquareUp_Pressed", {
                            GUID = "8af7c414-19dd-496c-94ad-e9a0d50494b2",
                        }),
                    },
                },
            },
            BLUE = {
                IDLE = T("PIP_UI_Button_Blue_Idle", {
                    GUID = "4f078b65-f58f-44fe-bc31-375f3dcfc8d6",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Blue_Highlighted", {
                    GUID = "86e93e09-2bf2-457d-8682-3f7ba073a870",
                }),
                PRESSED = T("PIP_UI_Button_Blue_Pressed", {
                    GUID = "bea60110-da7e-4515-88bf-78557cb5fa43",
                }),
                DISABLED = T("PIP_UI_Button_Blue_Disabled", {
                    GUID = "b3baf8d3-0421-4867-b126-974846e508bf",
                }),
            },
            CLOSE = {
                IDLE = T("PIP_UI_Button_Close_Idle", {
                    GUID = "08ce5ded-13cc-403c-a558-2abea90bd4dc",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Close_Highlighted", {
                    GUID = "2fead649-63b8-453f-aa7f-d853b2c39349",
                }),
                PRESSED = T("PIP_UI_Button_Close_Pressed", {
                    GUID = "11960ecb-8a92-40d6-81ce-8d0aa0273a16",
                }),
            },
            BROWN = {
                LARGE = {
                    IDLE = T("PIP_UI_Button_Brown_Large_Idle", {
                        GUID = "e0ff90f3-8ee1-4d5e-b4be-0e2bd5f13d15",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Brown_Large_Highlighted", {
                        GUID = "9312f60c-003b-4dae-b56d-32451bb57328",
                    }),
                    PRESSED = T("PIP_UI_Button_Brown_Large_Pressed", {
                        GUID = "56af3dce-e213-4500-8288-53f232c8bf74",
                    }),
                },
                SMALL = {
                    IDLE = T("PIP_UI_Button_Brown_Small_Idle", {
                        GUID = "7ca540d8-2316-4e96-8362-ab2a169fc39f",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Brown_Small_Highlighted", {
                        GUID = "1c9f3290-3ff1-42ae-b9f0-81b6e65dcfca",
                    }),
                    PRESSED = T("PIP_UI_Button_Brown_Small_Pressed", {
                        GUID = "fc98552c-4510-4d9e-8925-a7bd1c20c277",
                    }),
                    DISABLED = T("PIP_UI_Button_Brown_Small_Disabled", {
                        GUID = "5665179f-80f8-4b2a-b353-8c30349a98b0",
                    }),
                },
            },
            COUNTER = {
                DOS1 = {
                    DECREMENT = {
                        IDLE = T("PIP_UI_Button_DOS1_Decrement_Idle", {
                            GUID = "99020532-ed81-4aa4-9921-2c07d7d023dd",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_DOS1_Decrement_Highlighted", {
                            GUID = "06612655-8ac6-4113-8ed6-74ed4eba17dd",
                        }),
                        PRESSED = T("PIP_UI_Button_DOS1_Decrement_Pressed", {
                            GUID = "23fdf317-6a0c-4f78-abaa-d4217bc7b4bf",
                        }),
                    },
                    INCREMENT = {
                        IDLE = T("PIP_UI_Button_DOS1_Increment_Idle", {
                            GUID = "e2228a80-e9d3-417f-8158-6d48a9a3d6c4",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_DOS1_Increment_Highlighted", {
                            GUID = "8292a502-efaa-4413-a64f-5f0cfff5cdad",
                        }),
                        PRESSED = T("PIP_UI_Button_DOS1_Increment_Pressed", {
                            GUID = "44af4640-a9b4-415c-a825-df50f97afa76",
                        }),
                    },
                },
            },
            NOTCHES = {
                LARGE = {
                    IDLE = T("PIP_UI_Button_Notch_Large_Idle", {
                        GUID = "a0f25dc4-de9a-4195-913e-24177103df41",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Notch_Large_Highlighted", {
                        GUID = "5c137c7d-7c45-4156-a80b-a8a068ffbf98",
                    }),
                },
                SMALL = {
                    IDLE = T("PIP_UI_Button_Notch_Idle", {
                        GUID = "f8b5f6e8-da70-464e-8c9e-092ae21d4850",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Notch_Highlighted", {
                        GUID = "c8cc3ffc-d15d-4238-8f02-cf75675e52ad",
                    }),
                    PRESSED = T("PIP_UI_Button_Notch_Pressed", {
                        GUID = "1b14cfa1-26b0-41b5-b9ea-fd497174f5eb",
                    }),
                }
            },
            TRANSPARENT = {
                IDLE = T("PIP_UI_Button_Transparent_Idle", {
                    GUID = "a89be6ef-b0fd-4ad1-b567-a413fe2532f9",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Transparent_Highlighted", {
                    GUID = "e9394ad8-3d0e-4deb-81cf-1afc8aea7d01",
                }),
                PRESSED = T("PIP_UI_Button_Transparent_Pressed", {
                    GUID = "aa18593e-c725-421d-9bfc-7fec6bcfc30d",
                }),
            },
            RED = {
                LARGE = {
                    IDLE = T("PIP_UI_Button_Red_Large_Idle", {
                        GUID = "a9390fa2-3fb4-4ec6-96fe-e59c192633a0",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Red_Large_Highlighted", {
                        GUID = "29ae4f0c-0f8e-49e1-bea9-65414caad3bb",
                    }),
                    PRESSED = T("PIP_UI_Button_Red_Large_Pressed", {
                        GUID = "f98b5754-3e13-457b-9d3e-9f10604a5996",
                    }),
                },
                SMALL = {
                    IDLE = T("PIP_UI_Button_Red_Small_Idle", {
                        GUID = "e4a94a16-3037-4ea8-bd6d-31806f358127",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Red_Small_Highlighted", {
                        GUID = "c88d47bf-7a54-4e1f-b390-02ab2a8019a8",
                    }),
                    PRESSED = T("PIP_UI_Button_Red_Small_Pressed", {
                        GUID = "6d687541-bce6-4f6a-b1b2-953eb1465c52",
                    }),
                },
            },
        },
        STATE_BUTTONS = {
            CHECKBOXES = {
                ROUND = {
                    BACKGROUND = T("PIP_UI_StateButton_RoundCheckbox_Background", {
                        GUID = "40aad2c2-d1e6-407f-a15d-1772fdae6be2",
                    }),
                    CHECKMARK = T("PIP_UI_StateButton_RoundCheckbox_Checkmark", {
                        GUID = "48c0088b-6ecd-4636-826f-6e0c921a3c35",
                    }),
                },
                SIMPLE = {
                    BACKGROUND = T("PIP_UI_StateButton_SimpleCheckbox_Background", {
                        GUID = "0e9af3d9-e5be-4bbe-85a6-4a4783efc4c5",
                    }),
                    CHECKMARK = T("PIP_UI_StateButton_SimpleCheckbox_Checkmark", {
                        GUID = "9be5ac27-29c0-405c-91d7-a78c3105282e",
                    }),
                },
            },
        },
        FRAMES = {
            PORTRAIT = {
                BROWN = T("PIP_UI_Frame_Portrait_Brown", {
                    GUID = "5f6ae2a9-b815-4f07-909a-8dfc9ffcbd40",
                }),
                GOLDEN = T("PIP_UI_Frame_Portrait_Golden", {
                    GUID = "f77e3f35-314d-46cc-9440-500839a808dd",
                }),
                BEIGE = T("PIP_UI_Frame_Portrait_Beige", {
                    GUID = "1ec759f8-c08e-49ae-b7cf-cacf01071542",
                }),
                WHITE = T("PIP_UI_Frame_Portrait_White", {
                    GUID = "63bdce5b-41f5-4ea0-bd74-6fbc73b851f1",
                }),
            },
            RARITY = {
                UNCOMMON = T("PIP_UI_Frame_Rarity_Uncommon", {
                    GUID = "02fb99a3-ffcf-4891-a2fa-00c335eeeb80",
                }),
                RARE = T("PIP_UI_Frame_Rarity_Rare", {
                    GUID = "5e387734-26bf-4b0d-9205-e94d6657e82e",
                }),
                EPIC = T("PIP_UI_Frame_Rarity_Epic", {
                    GUID = "885fbb5b-7b5d-48bf-9aeb-11521e1ef413",
                }),
                LEGENDARY = T("PIP_UI_Frame_Rarity_Legendary", {
                    GUID = "6dc29d87-0522-4b7d-8244-ee87ab77ec0b",
                }),
                DIVINE = T("PIP_UI_Frame_Rarity_Divine", {
                    GUID = "517ced0d-1545-471d-ba5c-9bf87f48c077",
                }),
                UNIQUE = T("PIP_UI_Frame_Rarity_Unique", {
                    GUID = "ca088d7a-816b-4f42-87c7-62acd595a22c",
                }),
            },
            WHITE_TATTERED = T("PIP_UI_Frame_White_Tattered", {
                GUID = "aa2a1c49-b36f-4c59-b218-647e630e8763",
            }),
            BROWN = T("PIP_UI_Frame_Brown", {
                GUID = "e88f114a-ecd8-4560-960d-23d215977609",
            }),
            BROWN_SHADED = T("PIP_UI_Frame_Brown_Shaded", {
                GUID = "0e7c442d-e811-46d7-8228-62cfcd5c6535",
            }),
            DITTERED_CELL = T("PIP_UI_Frame_DitteredCell", {
                GUID = "7080d2ad-5f87-48fe-be08-5709a9498daa",
            }),
            TEAL_SHADED = T("PIP_UI_Frame_Teal_Shaded", {
                GUID = "01b09bfe-f0f4-401b-a045-710dd48706bb",
            }),
            WHITE_SHADED = T("PIP_UI_Frame_White_Shaded", {
                GUID = "495eb140-a594-4681-99f7-393a299d8eda",
            }),
        },
        PANELS = {
            CLIPBOARD = T("PIP_UI_Panel_Clipboard", {
                GUID = "de3756f6-4566-4be0-95b5-32f2b7706d68",
            }),
            CLIPBOARD_HEADERED = T("PIP_UI_Panel_Clipboard_Headered", {
                GUID = "67f908d0-04bf-4718-9c43-543f9f8fe4cb",
            }),
            CLIPBOARD_LARGE = T("PIP_UI_Panel_Clipboard_Large", {
                GUID = "c416e67c-339b-4527-937a-cc96cf9c93e8",
            }),
            DIALOGUE_CONTROLLER = T("PIP_UI_Panel_Dialogue_Controller", {
                GUID = "3ec1cc16-61f4-4a55-a4cb-fb0b994d6ad4",
            }),
            NOTE_CONTROLLER = T("PIP_UI_Panel_Note_Controller", {
                GUID = "6cc944eb-92e2-46d8-a360-f4454b0be1da",
            }),
            SKILLBOOK = T("PIP_UI_Panel_SkillBook", {
                GUID = "e4214879-bc18-4e72-94eb-fb3617d8d212",
            }),
            ALERT_TALL_CONTROLLER = T("PIP_UI_Panel_TallAlert_Controller", {
                GUID = "90fdb97a-38c2-4bfd-9eca-9df2ca866c19",
            }),
            ITEM_ALERT = T("PIP_UI_Panel_ItemAlert", {
                GUID = "1273b752-6d9b-4648-aecf-6bea0e56d94e",
            }),
            ITEM_ALERT_CONTROLLER = T("PIP_UI_Panel_ItemAlert_Controller", {
                GUID = "8269d380-5e4a-4f88-b375-e06f653d25c7",
            }),
            JOURNAL = T("PIP_UI_Panel_Journal", {
                GUID = "e77791ae-26b5-483a-8a94-a2f1aa42fcdf",
            }),
        },
        MISC = {
            BOOKMARK = T("PIP_UI_Misc_Bookmark", {
                GUID = "17729ed3-cf17-4654-978a-5c3e0ac8f7ed",
            }),
        }
    },
}
Epip.RegisterFeature("GenericUITextures", Textures)