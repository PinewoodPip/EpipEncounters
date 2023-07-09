
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
            HIGHLIGHT = T("PIP_UI_Background_Highlight", {
                GUID = "028e7d3c-0aad-4fff-b3ea-886984c2ffc9",
            }),
        },
        BUTTONS = {
            ADD = {
                SLOT = {
                    IDLE = T("PIP_UI_Button_Add_Slot_Idle", {
                        GUID = "1297e127-b5e7-478c-98ea-27af07ac8dd6",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Add_Slot_Highlighted", {
                        GUID = "2eb092dd-65a3-48f7-9407-466851e455ee",
                    }),
                },
            },
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
                DOWN_SLATE = {
                    IDLE = T("PIP_UI_Button_Down_Slate_Idle", {
                        GUID = "42537260-f580-4038-965e-fffe23a195e4",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Down_Slate_Highlighted", {
                        GUID = "9b8c2f69-1f36-496b-9ad2-0b1a985fe2f3",
                    }),
                    PRESSED = T("PIP_UI_Button_Down_Slate_Pressed", {
                        GUID = "adf42c0c-afb0-4b68-a671-6436accc7e05",
                    }),
                },
                DOWN_SLATE_SMALL = {
                    IDLE = T("PIP_UI_Button_Down_Slate_Small_Idle", {
                        GUID = "207d3e9f-1297-435d-89e5-63d5e898d34c",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Down_Slate_Small_Highlighted", {
                        GUID = "8eafb10e-3928-4a05-be46-285ef8a16596",
                    }),
                    PRESSED = T("PIP_UI_Button_Down_Slate_Small_Pressed", {
                        GUID = "5fe2e940-6824-4ee3-b449-c562bbb63f19",
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
                UP_SLATE = {
                    IDLE = T("PIP_UI_Button_Up_Slate_Idle", {
                        GUID = "01e254aa-9377-4f90-b16c-407e10e6557e",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Up_Slate_Highlighted", {
                        GUID = "db52e95c-677e-4f54-87c3-0467e3a0c4e6",
                    }),
                    PRESSED = T("PIP_UI_Button_Up_Slate_Pressed", {
                        GUID = "99237b6a-ef9e-4a92-8896-12691cdfc110",
                    }),
                },
                UP_SLATE_SMALL = {
                    IDLE = T("PIP_UI_Button_Up_Slate_Small_Idle", {
                        GUID = "33eeb6a4-349d-430a-8578-e77a0e14d142",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Up_Slate_Small_Highlighted", {
                        GUID = "9d9fdada-6814-4e87-8857-ca827b271ddb",
                    }),
                    PRESSED = T("PIP_UI_Button_Up_Slate_Small_Pressed", {
                        GUID = "d5827030-82a5-4f4c-93c9-d13cf168b513",
                    }),
                },
                LEFT_TALL = {
                    IDLE = T("PIP_UI_Button_Left_Tall_Idle", {
                        GUID = "fc8546b9-d755-4871-97aa-1b89f10f256b",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Left_Tall_Highlighted", {
                        GUID = "c7e00f44-0903-44d4-82e0-ef5e3d175514",
                    }),
                    PRESSED = T("PIP_UI_Button_Left_Tall_Pressed", {
                        GUID = "2de4778f-ba52-4b5e-a3c3-fdbaec962226",
                    }),
                },
                RIGHT_TALL = {
                    IDLE = T("PIP_UI_Button_Right_Tall_Idle", {
                        GUID = "8e4a4eae-988e-4c3c-af91-c31bd57189b9",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Right_Tall_Highlighted", {
                        GUID = "ab6a14ea-5127-408a-a9d2-3870b50c4d91",
                    }),
                    PRESSED = T("PIP_UI_Button_Right_Tall_Pressed", {
                        GUID = "c52f9fe3-d889-494f-9e2b-6e26dedc44a0",
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
                    DOWN = {
                        IDLE = T("PIP_UI_Button_SquareDown_Idle", {
                            GUID = "05dc9fee-0ba6-44ed-ac2f-b64037c14931",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_SquareDown_Highlighted", {
                            GUID = "de68367b-e9be-4eae-b559-a14e897ff0d1",
                        }),
                        PRESSED = T("PIP_UI_Button_SquareDown_Pressed", {
                            GUID = "95ef3563-5b8b-483e-b0ab-0de2cdcd36ef",
                        }),
                    },
                },
            },
            EDIT = {
                GREEN = {
                    IDLE = T("PIP_UI_Button_Edit_Green_Idle", {
                        GUID = "126ab9c7-5717-46b8-b726-065b518df0e6",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Edit_Green_Highlighted", {
                        GUID = "7e15aadc-ef13-4d8a-a37f-841de7fad035",
                    }),
                    PRESSED = T("PIP_UI_Button_Edit_Green_Pressed", {
                        GUID = "c1319247-f81f-45c9-96ec-130e7eaad1bb",
                    }),
                },
            },
            SAVE = {
                GREEN = {
                    IDLE = T("PIP_UI_Button_Save_Green_Idle", {
                        GUID = "8cac6c66-63c3-4743-bde8-a509414594fe",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Save_Green_Highlighted", {
                        GUID = "a71733c0-6c38-406a-a058-f3c03ae55fe0",
                    }),
                    PRESSED = T("PIP_UI_Button_Save_Green_Pressed", {
                        GUID = "5002baf8-dac8-45e6-88d8-795266b2e2d3",
                    }),
                },
            },
            INFO = {
                YELLOW = {
                    IDLE = T("PIP_UI_Button_Info_Idle", { -- TODO add yellow suffix
                        GUID = "da6d47fb-d359-4c15-b7af-464fb3a1b6f3",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Info_Highlighted", {
                        GUID = "14083033-fe69-4888-bbc7-a53afc413a3b",
                    }),
                },
            },
            MENU = {
                SLATE = {
                    IDLE = T("PIP_UI_Button_Menu_Slate_Idle", {
                        GUID = "c579fd41-bda6-4767-b731-ccee798f0ac2",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Menu_Slate_Highlighted", {
                        GUID = "bada3e65-ce2d-4c15-a480-a7669e3023b0",
                    }),
                },
                SLATE_TALL = {
                    IDLE = T("PIP_UI_Button_Menu_Slate_Tall_Idle", {
                        GUID = "cf9d7c37-c462-42c9-9d93-88a922b834cc",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Menu_Slate_Tall_Highlighted", {
                        GUID = "94e0e766-0885-423a-8445-353b8363016e",
                    }),
                    PRESSED = T("PIP_UI_Button_Menu_Slate_Tall_Pressed", {
                        GUID = "07027362-a63b-4ecf-930c-e83dc994ca06",
                    }),
                },
            },
            TRADE = {
                LARGE = {
                    IDLE = T("PIP_UI_Button_Trade_Large_Idle", {
                        GUID = "4753e44c-5fef-4523-b588-8781b2853403",
                    }),
                    PRESSED = T("PIP_UI_Button_Trade_Large_Pressed", {
                        GUID = "33180988-edea-49e2-952f-8df0123240b5",
                    }),
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
            GREEN = {
                MEDIUM = {
                    IDLE = T("PIP_UI_Button_Green_Medium_Idle", {
                        GUID = "a388f257-880b-4a80-9293-fcca1d443e37",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Green_Medium_Highlighted", {
                        GUID = "fdc40399-222d-4393-9b20-273b94170e5e",
                    }),
                    PRESSED = T("PIP_UI_Button_Green_Medium_Pressed", {
                        GUID = "c637b928-73d7-4e5f-9978-f0f7d7449ae5",
                    }),
                    DISABLED = T("PIP_UI_Button_Green_Medium_Disabled", {
                        GUID = "ce98d1cc-20e0-4256-9f52-953b9635678f",
                    }),
                }
            },
            SQUARE = {
                STONE = {
                    IDLE = T("PIP_UI_Button_Stone_Square_Idle", {
                        GUID = "d799321b-e513-48c4-bef1-13b9fe40a123",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Stone_Square_Highlighted", {
                        GUID = "3b19d309-1e72-4590-b7b8-812e6e95f0f3",
                    }),
                    PRESSED = T("PIP_UI_Button_Stone_Square_Pressed", {
                        GUID = "ba9d1435-8e2b-4b93-a0df-e1af1d28c72e",
                    }),
                    DISABLED = T("PIP_UI_Button_Stone_Square_Disabled", {
                        GUID = "a7944143-9a31-43b0-99a2-affd4cf13391",
                    }),
                },
            },
            LABEL = {
                POINTY = {
                    IDLE = T("PIP_UI_Button_Label_Pointy_Idle", {
                        GUID = "680be6ca-cbb0-4e71-b02c-35ee6b3cfc4b",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Label_Pointy_Highlighted", {
                        GUID = "9c01ad02-56fa-4927-9642-77dc593292ac",
                    }),
                },
            },
            CLOSE = {
                BACKGROUNDLESS = {
                    IDLE = T("PIP_UI_Button_Close_Backgroundless_Idle", {
                        GUID = "c689c9ec-addf-4ca0-9e72-4ebaf5a02c8f",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Close_Backgroundless_Highlighted", {
                        GUID = "c44708a9-0728-455b-a589-e48ca3e284ce",
                    }),
                    PRESSED = T("PIP_UI_Button_Close_Backgroundless_Pressed", {
                        GUID = "5e95599b-4126-4b6b-b293-45425053641f",
                    }),
                },
                DOS1_SQUARE = {
                    IDLE = T("PIP_UI_Button_Close_DOS1_Square_Idle", {
                        GUID = "d48c2636-311f-4512-8088-99ffc91752b7",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Close_DOS1_Square_Highlighted", {
                        GUID = "60115b12-7f33-42ed-9712-a76a38077380",
                    }),
                    PRESSED = T("PIP_UI_Button_Close_DOS1_Square_Pressed", {
                        GUID = "a55dfe69-7f97-4595-baf4-287cd6daf653",
                    }),
                },
                SLATE = {
                    IDLE = T("PIP_UI_Button_Close_Slate_Idle", {
                        GUID = "fafaf362-0fae-444f-b2d1-cf733493096f",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Close_Slate_Highlighted", {
                        GUID = "4196104c-53a7-42ca-806e-c2a1defe0642",
                    }),
                    PRESSED = T("PIP_UI_Button_Close_Slate_Pressed", {
                        GUID = "560825a4-f558-4c55-b4f8-aa8eac01416b",
                    }),
                },
                STONE = {
                    IDLE = T("PIP_UI_Button_Close_Stone_Idle", {
                        GUID = "63b28c6c-9718-4c9e-8826-8408e643c944",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Close_Stone_Highlighted", {
                        GUID = "df1add32-affd-418b-a487-a1591976b410",
                    }),
                    PRESSED = T("PIP_UI_Button_Close_Stone_Pressed", {
                        GUID = "1337f4cf-1206-46a2-9962-48d6f1c1eddf",
                    }),
                },

                -- TODO reorganize
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
            CLOSE_GREEN = {
                IDLE = T("PIP_UI_Button_Close_Green_Idle", {
                    GUID = "74be9fd3-88dd-4d38-a5ab-f93a04ba4dad",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Close_Green_Highlighted", {
                    GUID = "58ad23f9-4556-45d6-9564-8dd45b7df5fc",
                }),
                PRESSED = T("PIP_UI_Button_Close_Green_Pressed", {
                    GUID = "8c1d038d-dd8a-4029-83f5-859faf881961",
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
                DOS1 = {
                    IDLE = T("PIP_UI_Button_Red_DOS1_Idle", {
                        GUID = "c90bd61b-a8cb-4982-8240-e819174c99d0",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Red_DOS1_Highlighted", {
                        GUID = "a8f497b4-570b-435d-a7d4-3e6d82329993",
                    }),
                    PRESSED = T("PIP_UI_Button_Red_DOS1_Pressed", {
                        GUID = "69c46608-062e-46b3-9ac0-9f80d9d76fea",
                    }),
                    DISABLED = T("PIP_UI_Button_Red_DOS1_Disabled", {
                        GUID = "a9a6029b-9271-4e27-9668-1a16b99947d2",
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
                    BACKGROUND_HIGHLIGHTED = T("PIP_UI_StateButton_SimpleCheckbox_Background_Highlighted", {
                        GUID = "d187a5d4-368d-496a-8cc1-3e5c87407b18",
                    }),
                    CHECKMARK = T("PIP_UI_StateButton_SimpleCheckbox_Checkmark", {
                        GUID = "9be5ac27-29c0-405c-91d7-a78c3105282e",
                    }),
                    CHECKMARK_HIGHLIGHTED = T("PIP_UI_StateButton_SimpleCheckbox_Checkmark_Highlighted", {
                        GUID = "74bae148-ef0d-4aaf-9115-45cf8cf5ceae",
                    }),
                },
                SIMPLE_SMALL = {
                    BACKGROUND_INACTIVE_IDLE = T("PIP_UI_StateButton_SimpleCheckbox_Small_Inactive_Idle", {
                        GUID = "b466a7c2-384a-407c-a951-e252e0298b15",
                    }),
                    BACKGROUND_INACTIVE_HIGHLIGHTED = T("PIP_UI_StateButton_SimpleCheckbox_Small_Inactive_Highlighted", {
                        GUID = "ca0441c2-24ec-4b10-88cb-2b6f7bb17c56",
                    }),
                    BACKGROUND_ACTIVE_IDLE = T("PIP_UI_StateButton_SimpleCheckbox_Small_Active_Idle", {
                        GUID = "87cf7a87-ae08-4550-b3f0-2fe150953038",
                    }),
                    BACKGROUND_ACTIVE_HIGHLIGHTED = T("PIP_UI_StateButton_SimpleCheckbox_Small_Active_Highlighted", {
                        GUID = "1f9d08ca-c0ed-401b-a331-eddcc2c79688",
                    }),
                },
                STONE = {
                    BACKGROUND_INACTIVE_IDLE = T("PIP_UI_StateButton_StoneCheckbox_Inactive_Idle", {
                        GUID = "42e947b9-5faa-49af-b974-95890cc8473b",
                    }),
                    BACKGROUND_INACTIVE_HIGHLIGHTED = T("PIP_UI_StateButton_StoneCheckbox_Inactive_Highlighted", {
                        GUID = "92539240-9417-4e5f-8e74-f18174cd1244",
                    }),
                    BACKGROUND_INACTIVE_PRESSED = T("PIP_UI_StateButton_StoneCheckbox_Inactive_Pressed", {
                        GUID = "a4b78f82-19f2-4043-8bf7-e3776494b325",
                    }),
                    BACKGROUND_ACTIVE_IDLE = T("PIP_UI_StateButton_StoneCheckbox_Active_Idle", {
                        GUID = "81dc95f2-7ceb-4511-9762-a9b07b8cde7c",
                    }),
                    BACKGROUND_ACTIVE_HIGHLIGHTED = T("PIP_UI_StateButton_StoneCheckbox_Active_Highlighted", {
                        GUID = "958f51b1-b6d0-4159-93a5-056101b5caa0",
                    }),
                    BACKGROUND_ACTIVE_PRESSED = T("PIP_UI_StateButton_StoneCheckbox_Active_Pressed", {
                        GUID = "2a8a4b8d-7994-4673-be0f-47b2201e4641",
                    }),
                },
                FORM = {
                    BACKGROUND_IDLE = T("PIP_UI_StateButton_FormCheckbox_Background_Idle", {
                        GUID = "1daf0357-75cf-4dfe-a4f3-84bde1aee747",
                    }),
                    BACKGROUND_HIGHLIGHTED = T("PIP_UI_StateButton_FormCheckbox_Background_Highlighted", {
                        GUID = "9aabc680-932d-4461-ad1a-83b5dd8a0db6",
                    }),
                    BACKGROUND_PRESSED = T("PIP_UI_StateButton_FormCheckbox_Background_Pressed", {
                        GUID = "d1dce1a8-d5a9-4c11-a7b2-edbe8c89c845",
                    }),
                    CHECKMARK = T("PIP_UI_StateButton_FormCheckbox_Checkmark", {
                        GUID = "f760fa05-a95d-4d72-be68-b2acb30b4d07",
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
                SMALL = {
                    IDLE = T("PIP_UI_Frame_Portrait_Small_Idle", {
                        GUID = "86b41e73-4a68-4f3f-bbb2-8446e17de963",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Frame_Portrait_Small_Highlighted", {
                        GUID = "e11194b4-0027-44a1-90eb-ed878389b725",
                    }),
                    PRESSED = T("PIP_UI_Frame_Portrait_Small_Pressed", {
                        GUID = "8dd6f901-c11b-416c-b9db-232c917dcbe4",
                    }),
                    DISABLED = T("PIP_UI_Frame_Portrait_Small_Disabled", {
                        GUID = "bf0b1a31-2f5c-42c9-8b9b-502f5a290c68",
                    }),
                },
                SIMPLE = {
                    BRASS = T("PIP_UI_Frame_Portrait_Simple_Brass", {
                        GUID = "1e016d59-6f0a-41e2-ac7a-cb7668de01a0",
                    }),
                    BLUE = T("PIP_UI_Frame_Portrait_Simple_Blue", {
                        GUID = "813fc9f1-f547-42ee-acd9-c8631cba3a06",
                    }),
                    GLOWING = T("PIP_UI_Frame_Portrait_Simple_Glowing", {
                        GUID = "692d8ad1-66fa-49ad-b1b1-cf58363cd2b9",
                    }),
                    GREEN = T("PIP_UI_Frame_Portrait_Simple_Green", {
                        GUID = "e1f079f5-f366-45ac-8a4d-44cd86af109f",
                    }),
                    RED = T("PIP_UI_Frame_Portrait_Simple_Red", {
                        GUID = "174328c6-ed7c-4130-8550-ee941569d8cb",
                    }),
                    WHITE = T("PIP_UI_Frame_Portrait_Simple_White", {
                        GUID = "c43cfd5d-e9cb-4ef3-b166-43681859aef2",
                    }),
                    YELLOW = T("PIP_UI_Frame_Portrait_Simple_Yellow", {
                        GUID = "532ac557-b870-4508-a6ea-8021126fe73e",
                    }),
                },
                COMBAT = {
                    BLUE = T("PIP_UI_Frame_Portrait_Combat_Blue", {
                        GUID = "7f9b986b-6333-4556-9056-79a0e3326e7d",
                    }),
                    GREEN = T("PIP_UI_Frame_Portrait_Combat_Green", {
                        GUID = "d455577b-f70d-41c3-814a-db26a4b0c6db",
                    }),
                    WHITE = T("PIP_UI_Frame_Portrait_Combat_White", {
                        GUID = "80f2e805-1956-4630-bdbd-e65aa9532192",
                    }),
                    YELLOW = T("PIP_UI_Frame_Portrait_Combat_Yellow", {
                        GUID = "befa5351-98ac-4879-b7c4-b5570d9f1572",
                    }),
                },
            },
            SLOT = {
                LABELED = {
                    TATTERED = T("PIP_UI_Frame_LabeledSlot_Tattered", {
                        GUID = "d18bd2f8-d0ab-4736-a9c5-d68b7114f825",
                    }),
                },
                ADD = {
                    BEIGE = T("PIP_UI_Frame_Slot_Add_Beige", {
                        GUID = "bbeae4b1-9dd2-41a7-a0bc-39eeb2e481a7",
                    }),
                    BLUE = T("PIP_UI_Slot_Add_Blue", { -- TODO fix name; missing frame prefix
                        GUID = "9160c159-7085-41ab-9b87-3a22c038de61",
                    }),
                },
                FANCY_LARGE = T("PIP_UI_Frame_Slot_Fancy_Large", {
                    GUID = "12db1336-372c-4272-a422-c3fc99add409",
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
            WHITE_GLOWING = T("PIP_UI_Frame_White_Glowing", {
                GUID = "7399d28f-cc22-494b-be9c-fb0843fd74c7",
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
            CLIPBOARD_SMALL = T("PIP_UI_Panel_Clipboard_Small", {
                GUID = "6624ce8e-5acd-4e3d-99e9-8efb8d34c3dc",
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
            PROMPT_CONTROLLER = T("PIP_UI_Panel_Prompt_Controller", {
                GUID = "3a5647b6-9e61-451e-a80b-4a6ea3ffbc21",
            }),
        },
        MISC = {
            BOOKMARK = T("PIP_UI_Misc_Bookmark", {
                GUID = "17729ed3-cf17-4654-978a-5c3e0ac8f7ed",
            }),
            BLACK_BLUR_DOT = T("PIP_UI_Misc_BlackBlurDot", {
                GUID = "df749401-f928-4712-986a-4a57d91bf5f9",
            }),
            TEAM_FABRICS = {
                LARGE = {
                    IDLE = {
                        BLACK = T("PIP_UI_Misc_Fabric_Team_Black_Large", {
                            GUID = "0307d1b8-fba5-40b2-a277-2d9385126fd4",
                        }),
                        BLUE = T("PIP_UI_Misc_Fabric_Team_Blue_Large", {
                            GUID = "8d7dc265-4376-4b65-926a-b91f2f0c055a",
                        }),
                        GREEN = T("PIP_UI_Misc_Fabric_Team_Green_Large", {
                            GUID = "00b7f0d4-9519-4560-b4cf-c17b74233077",
                        }),
                        RED = T("PIP_UI_Misc_Fabric_Team_Red_Large", {
                            GUID = "52df600c-efbc-429c-bb63-93ec1afd8efe",
                        }),
                        YELLOW = T("PIP_UI_Misc_Fabric_Team_Yellow_Large", {
                            GUID = "ee58272d-4406-4f2e-9095-9acd12571934",
                        }),
                    },
                    HIGHLIGHTED = {
                        BLACK = T("PIP_UI_Misc_Fabric_Team_Black_Large_Highlighted", {
                            GUID = "a412a2c4-4b3d-4138-a8d5-411b9c49521a",
                        }),
                        BLUE = T("PIP_UI_Misc_Fabric_Team_Blue_Large_Highlighted", {
                            GUID = "dc2d9769-b750-4801-a044-986f43beb79b",
                        }),
                        GREEN = T("PIP_UI_Misc_Fabric_Team_Green_Large_Highlighted", {
                            GUID = "660f2776-49cb-4856-9aae-55e442dd3d56",
                        }),
                        RED = T("PIP_UI_Misc_Fabric_Team_Red_Large_Highlighted", {
                            GUID = "feb778e5-2cac-491c-b61f-5da3bbcee960",
                        }),
                        YELLOW = T("PIP_UI_Misc_Fabric_Team_Yellow_Large_Highlighted", {
                            GUID = "7c48c84c-2201-44fc-9979-5a84d12f2844",
                        }),
                    },
                },
            },
            ORANGE_HALO = T("PIP_UI_Misc_OrangeHalo", {
                GUID = "c1eb5800-afd0-4345-8180-375d35cde8bb",
            }),
        },
    },
    ICONS = {
        ACTION_POINTS = {
            -- 24x
            COST = {
                IDLE = "PIP_UI_Icon_Resource_AP_Cost",
                HIGHLIGHTED = "PIP_UI_Icon_Resource_AP_Cost_Highlighted",
            },
            -- 24x
            IDLE = {
                IDLE = "PIP_UI_Icon_Resource_AP_Idle",
                HIGHLIGHTED = "PIP_UI_Icon_Resource_AP_Highlighted",
            },
            BORDERED = "PIP_UI_Icon_ActionPoint_Bordered", -- 28x
            SIMPLE_EMPTY = "PIP_UI_Icon_AP_Simple_Empty", -- 28x
            SIMPLE = "PIP_UI_Icon_AP_Simple", -- 32x
        },
        ARMOR_TYPES = {
            MAGIC = "PIP_UI_Icon_Armor_Magic", -- 28x
            PHYSICAL = "PIP_UI_Icon_Armor_Physical", -- 28x
        },
        ATTRIBUTES = {
            STRENGTH = {
                DARK = "PIP_UI_Icon_Attribute_Strength_Dark", -- 48x
            },
            FINESSE = {
                DARK = "PIP_UI_Icon_Attribute_Finesse_Dark", -- 48x
            },
            INTELLIGENCE = {
                DARK = "PIP_UI_Icon_Attribute_Intelligence_Dark", -- 48x
            },
            CONSTITUTION = {
                DARK = "PIP_UI_Icon_Attribute_Constitution_Dark", -- 48x
            },
            MEMORY = {
                DARK = "PIP_UI_Icon_Attribute_Memory_Dark", -- 48x
            },
            WITS = {
                DARK = "PIP_UI_Icon_Attribute_Wits_Dark", -- 48x
            },
        },
        CHECKMARKS = {
            PINK = "PIP_UI_Icon_Checkmark_Pink", -- 16x
            -- 36x
            TEAM = {
                BLUE = "PIP_UI_Icon_TeamCheckmark_Blue",
                GREEN = "PIP_UI_Icon_TeamCheckmark_Green",
                RED = "PIP_UI_Icon_TeamCheckmark_Red",
                WHITE = "PIP_UI_Icon_TeamCheckmark_White",
                YELLOW = "PIP_UI_Icon_TeamCheckmark_Yellow",
            }
        },
        COINS = {
            SMALL = "PIP_UI_Icon_Coin_Small", -- 16x
        },
        -- 32x
        COMBAT_LOG_FILTERS = {
            ANNOUNCEMENTS = "PIP_UI_Icon_CombatLogFilter_Announcements",
            COMBAT = "PIP_UI_Icon_CombatLogFilter_Combat",
            DIALOG = "PIP_UI_Icon_CombatLogFilter_Dialogue",
            ITEMS = "PIP_UI_Icon_CombatLogFilter_Items",
            ROLLS = "PIP_UI_Icon_CombatLogFilter_Rolls",
        },
        CROSSES = {
            RED_SMALL = "PIP_UI_Icon_RedX_Small", -- 20x
        },
        CROWNS = {
            WHITE = "PIP_UI_Icon_Crown_White", -- 24x
            GOLD = "PIP_UI_Icon_Crown_Gold", -- 32x
        },
        DIAMOND_MINUS_X = {
            BLACK = "PIP_UI_Icon_BlackDiamondMinusWhiteX", -- 16x
            BLUE = "PIP_UI_Icon_BlueDiamondMinusWhiteX", -- 16x
            GREEN = "PIP_UI_Icon_GreenDiamondMinusWhiteX", -- 16x
        },
        -- 80x
        DIFFICULTIES = {
            STORY = "PIP_UI_Icon_Difficulty_Story",
            EXPLORER = "PIP_UI_Icon_Difficulty_Explorer",
            CLASSIC = "PIP_UI_Icon_Difficulty_Classic",
            HONOUR = "PIP_UI_Icon_Difficulty_Honour",
            TACTICIAN = "PIP_UI_Icon_Difficulty_Tactician",
        },
        EQUIPMENT_SLOTS = {
            WEAPON = "PIP_UI_Icon_Weapon_Bordered", -- 28x
            ARMOR = "PIP_UI_Icon_Armor_Bordered", -- 28x
            JEWELRY = "PIP_UI_Icon_Jewelry_Bordered", -- 28x
        },
        -- 40x
        FRAMED_GEMS = {
            BLUE = "PIP_UI_Icon_FramedGem_Blue",
            GREEN = "PIP_UI_Icon_FramedGem_Green",
            RED = "PIP_UI_Icon_FramedGem_Red",
            YELLOW = "PIP_UI_Icon_FramedGem_Yellow",
        },
        -- 64x
        INSTRUMENTS = {
            BANSURI = "PIP_UI_Icon_Instrument_Bansuri",
            CELLO = "PIP_UI_Icon_Instrument_Cello",
            OUD = "PIP_UI_Icon_Instrument_Oud",
            TAMBURA = "PIP_UI_Icon_Instrument_Tambura",
        },
        INTERFACES = {
            CRAFT = {
                SHADED = "PIP_UI_Icon_Interface_Craft_Shaded", -- 32x
                WHITE = "PIP_UI_Icon_Interface_Craft_White", -- 32x
            },
        },
        JOURNAL = {
            MINUS = "PIP_UI_Icon_Journal_MinusSign", -- 24x
            PLUS = "PIP_UI_Icon_Journal_PlusSign", -- 24x
            DIAMOND_1 = "PIP_UI_Icon_JournalDiamond_1", -- 24x
            DIAMOND_2 = "PIP_UI_Icon_JournalDiamond_2", -- 24x
            DIAMOND_EMPTY = "PIP_UI_Icon_JournalDiamond_Empty", -- 24x
            FLAGS = {
                BLACK = "PIP_UI_Icon_JournalFlag_Black", -- 32x
                BLUE = "PIP_UI_Icon_JournalFlag_Blue", -- 44x
            }
        },
        LOCKS = {
            SMALL = "PIP_UI_Icon_Lock_Small", -- 16x
        },
        MISC = {
            TREASURE_CHEST = "PIP_UI_Icon_TreasureChest", -- 48x
            GOLD_HELMET = "PIP_UI_Icon_GoldHelmet", -- 24x
            FAST_TRAVEL = "PIP_UI_Icon_FastTravel", -- 48x
        },
        RUNES = {
            SLOT = "PIP_UI_Icon_Rune_Bordered", -- 28x
        },
        SOURCE_POINT = {
            IDLE = "PIP_UI_Icon_SourcePoint_Idle", -- 20x
            HIGHLIGHTED = "PIP_UI_Icon_SourcePoint_Highlighted", -- 20x
            BORDERED = "PIP_UI_Icon_SourcePoint_Bordered",
        },
        SKILL_SCHOOL_WHITE_TEMPLATE = "PIP_UI_Icon_SkillSchool_%s_White", -- 44x
        SKILL_SCHOOL_COLORED_TEMPLATE = "PIP_UI_Icon_SkillSchool_%s_Colored", -- 44x
        STARS = {
            BLUE = "PIP_UI_Icon_BlueStar", -- 24x
            YELLOW_LARGE = "PIP_UI_Icon_Star_Large", -- 36x
        },
        STATS = {
            CRITICAL_CHANCE = "PIP_UI_Icon_CriticalChance", -- 24x
            -- 24x
            MEMORY_COST = {
                "PIP_UI_Icon_MemoryCost_1",
                "PIP_UI_Icon_MemoryCost_2",
                "PIP_UI_Icon_MemoryCost_3",
                "PIP_UI_Icon_MemoryCost_4",
            },
            VITALITY = "PIP_UI_Icon_Resource_Health", -- 24x
        },
        TABS = {
            BOOKS_AND_KEYS = {
                SHADED = "PIP_UI_Icon_Tab_BooksAndKeys_Trade", -- 32x
            },
            EQUIPMENT = {
                SHADED = "PIP_UI_Icon_Tab_Equipment_Trade", -- 32x
            },
            MAGICAL = {
                WHITE = "PIP_UI_Icon_Tab_Magical", -- 32x
            },
            POTIONS = {
                WHITE = "PIP_UI_Icon_Tab_Potions", -- 32x
            },
            WARES = {
                WHITE = "PIP_UI_Icon_Tab_Wares", -- 32x
            },
            BUY_BACK = "PIP_UI_Icon_Tab_Buyback", -- 32x
        },
        QUEST_FLAGS = {
            BLUE = "PIP_UI_Icon_Flag_Blue", -- 48x
            RED = "PIP_UI_Icon_Flag_Red", -- 48x
            YELLOW = "PIP_UI_Icon_Flag_Yellow", -- 48x
        }
    },
}
Epip.RegisterFeature("GenericUITextures", Textures)