
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
            DOS1_EXAMINE = T("PIP_UI_Background_Page_DOS1_Examine", {
                GUID = "1743ce49-7909-4954-a1dd-dc81353530a7",
            }),
            NOTEBOOK = T("PIP_UI_Background_Notebook", {
                GUID = "6b99397a-46bc-4de8-90c0-31658cb7aaed",
            }),
        },
        BARS = {
            LOADING_SCREEN = T("PIP_UI_Bar_LoadingScreen", {
                GUID = "7403b92e-0439-4a70-9c35-c7f9bf4fb0ad",
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
                DOWN_GREEN = {
                    IDLE = T("PIP_UI_Button_Down_Green_Idle", {
                        GUID = "769da36d-aa45-453b-b4ec-ae6fb20b36a5",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Down_Green_Highlighted", {
                        GUID = "99d21d36-0511-463c-9077-0b1cb48667e5",
                    }),
                    PRESSED = T("PIP_UI_Button_Down_Green_Pressed", {
                        GUID = "a54c47e7-5734-4d16-a852-22cbecfd73a7",
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
                UP_BROWN_SMALL = {
                    IDLE = T("PIP_UI_Button_Up_BrownSmall_Idle", {
                        GUID = "8be56f38-a7a4-4e33-b846-83b56d80b86b",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Up_BrownSmall_Highlighted", {
                        GUID = "8a495747-0aa9-44ff-a10c-e3a4b82268d4",
                    }),
                    PRESSED = T("PIP_UI_Button_Up_BrownSmall_Pressed", {
                        GUID = "4b2816bb-ab88-4262-b151-fb72cebbf650",
                    }),
                },
                DOWN_BROWN_SMALL = {
                    IDLE = T("PIP_UI_Button_Down_BrownSmall_Idle", {
                        GUID = "d0993808-bd4b-4da4-b951-9267fe21b3ac",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Down_BrownSmall_Highlighted", {
                        GUID = "c36bc852-c7c5-4c6f-b34e-5a4da3b71283",
                    }),
                    PRESSED = T("PIP_UI_Button_Down_BrownSmall_Pressed", {
                        GUID = "509e6dfa-9371-4f36-a94b-5e090cef1f6d",
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
                UP_DIAMOND = {
                    IDLE = T("PIP_UI_Button_Arrow_Up_Idle", {
                        GUID = "4340389a-d311-42d6-bed1-6ce7ba6e9f02",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Arrow_Up_Highlighted", {
                        GUID = "a53f433c-0f52-4bba-80b7-ccd66d730e72",
                    }),
                    PRESSED = T("PIP_UI_Button_Arrow_Up_Pressed", {
                        GUID = "898b683c-40e1-48a9-bfa1-cbe95f0599d7",
                    }),
                    DISABLED = T("PIP_UI_Button_Arrow_Up_Disabled", {
                        GUID = "17ab2870-d6f0-468b-a882-d52b1dac2fbc",
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
                LEFT_CHARACTER_SHEET = {
                    IDLE = T("PIP_UI_Button_Left_CharacterSheet_Idle", {
                        GUID = "e91cf8b3-2781-4628-8e5e-d6a020e2e078",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Left_CharacterSheet_Highlighted", {
                        GUID = "0e3595f9-702d-4927-824f-9438638de6e9",
                    }),
                    PRESSED = T("PIP_UI_Button_Left_CharacterSheet_Pressed", {
                        GUID = "0a85c3cf-3469-4d4a-8b03-d8c6dd3d21a7",
                    }),
                },
                LEFT_DECORATED = {
                    IDLE = T("PIP_UI_Button_Left_Decorated_Idle", {
                        GUID = "bc3fcd54-c231-4b7a-b522-bc7639656d49",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Left_Decorated_Highlighted", {
                        GUID = "2e19a5d5-0903-40dc-aa7d-94fbffd22eb3",
                    }),
                    PRESSED = T("PIP_UI_Button_Left_Decorated_Pressed", {
                        GUID = "449325c6-2795-49a5-8635-51f87f20c6cb",
                    }),
                    DISABLED = T("PIP_UI_Button_Left_Decorated_Disabled", {
                        GUID = "d3a97195-f10b-4a5f-b9cb-cf8df1b30db3",
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
                RIGHT_CHARACTER_SHEET = {
                    IDLE = T("PIP_UI_Button_Right_CharacterSheet_Idle", {
                        GUID = "b2c11c08-a2ef-4673-bfe3-1092ddea2025",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Right_CharacterSheet_Highlighted", {
                        GUID = "002f31d6-9c07-41c0-9076-a262f006f186",
                    }),
                    PRESSED = T("PIP_UI_Button_Right_CharacterSheet_Pressed", {
                        GUID = "09d70662-a1c9-4730-88ee-9e9913a71da8",
                    }),
                },
                RIGHT_DECORATED = {
                    IDLE = T("PIP_UI_Button_Right_Decorated_Idle", {
                        GUID = "f00eb1d4-8b63-4883-bf6e-96f477665116",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Right_Decorated_Highlighted", {
                        GUID = "448ca995-d43e-471d-97cd-73c913bd5713",
                    }),
                    PRESSED = T("PIP_UI_Button_Right_Decorated_Pressed", {
                        GUID = "a776ed78-ba69-432e-afdf-47100bebe7db",
                    }),
                    DISABLED = T("PIP_UI_Button_Right_Decorated_Disabled", {
                        GUID = "d0de2602-25ce-4f44-a7f7-bebae4c73e4d",
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
                        IDLE = T("PIP_UI_Button_Diamond_Idle_Alt", {
                            GUID = "48451d79-6e88-4600-8b0e-478b18d21616",
                        }),
                        PRESSED = T("PIP_UI_Button_Diamond_Idle", {
                            GUID = "52057ae6-2938-4af6-83c2-bf84d1eeb8bd",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Diamond_Highlighted", {
                            GUID = "93d4308e-f238-41d5-80b7-30cadbeb57bb",
                        }),
                        DISABLED = T("PIP_UI_Button_Diamond_Disabled", {
                            GUID = "269c2e0d-e840-42f7-8707-05f1f582327b",
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
                    UP_DOUBLE = {
                        IDLE = T("PIP_UI_Button_Up_DoubleArrow_Idle", {
                            GUID = "96a17b83-7841-4bb0-9422-f6982f65bd53",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Up_DoubleArrow_Highlighted", {
                            GUID = "9c009eb2-dfc6-4532-b86f-ba3636af1781",
                        }),
                        PRESSED = T("PIP_UI_Button_Up_DoubleArrow_Disabled", {
                            GUID = "c74fe0c9-2416-4b0c-bc5e-ed5916a42e3a",
                        }),
                        DISABLED = T("PIP_UI_Button_Up_DoubleArrow_Disabled_Alt", {
                            GUID = "f31b1993-35a1-4e8c-9540-a73a69876106",
                        }),
                    },
                    DOUBLE = {
                        IDLE = T("PIP_UI_Button_DoubleDiamond_Idle_Alt", {
                            GUID = "6a43d098-c8a8-4d2c-8500-cb3359545220",
                        }),
                        PRESSED = T("PIP_UI_Button_DoubleDiamond_Idle", {
                            GUID = "8be86e73-da60-4d71-9631-30b175932501",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_DoubleDiamond_Highlighted", {
                            GUID = "801eae78-6f28-46c5-b3a6-671ec44ce248",
                        }),
                        DISABLED = T("PIP_UI_Button_DoubleDiamond_Disabled", {
                            GUID = "ca5a256f-7b99-480c-9a0c-bb5c95b88680",
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
            EDIT_WIDE = {
                IDLE = T("PIP_UI_Button_Edit_Wide_Idle", {
                    GUID = "915ecaf0-198e-407d-a016-2f705bced53e",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Edit_Wide_Highlighted", {
                    GUID = "ac1aa622-2b15-4304-b942-cdb2402b601a",
                }),
                PRESSED = T("PIP_UI_Button_Edit_Wide_Pressed", {
                    GUID = "c1a7b065-06e1-4bd0-8116-bba5562a5ebd",
                }),
            },
            SETTINGS = {
                RED = {
                    IDLE = T("PIP_UI_Button_Settings_Red_Idle", {
                        GUID = "592dd6e8-ee24-4d31-aa0b-85e18cf503e2",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Settings_Red_Highlighted", {
                        GUID = "f5cfc635-300e-4d91-95e5-e9c3b8816666",
                    }),
                    -- TODO rename texture file
                    PRESSED = T("PIP_UI_Button_Settings_Red_Disabled", {
                        GUID = "2289750b-e8da-4570-bed3-7a99c5fc2d99",
                    }),
                },
            },
            STOP = {
                RED = {
                    IDLE = T("PIP_UI_Button_Stop_Idle", {
                        GUID = "8fb1fe75-6d8f-4957-9a34-e4f76bd9ea07",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Stop_Highlighted", {
                        GUID = "5d821ee2-f035-4cd2-9ae1-00305326da3b",
                    }),
                    PRESSED = T("PIP_UI_Button_Stop_Pressed", {
                        GUID = "eacebbdb-0542-4bc4-8d89-340b72c8d15f",
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
            CANCEL = {
                LISTEN = {
                    IDLE = T("PIP_UI_Button_Cancel_Listen_Idle", {
                        GUID = "62721ced-269a-48e4-b54f-94aba8499743",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Cancel_Listen_Highlighted", {
                        GUID = "d7dbf64b-a3ab-4d47-b3b2-67db208a100a",
                    }),
                    PRESSED = T("PIP_UI_Button_Cancel_Listen_Pressed", {
                        GUID = "83e77eeb-5dca-47ad-bb6f-8acc2cf774d5",
                    }),
                }
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
                DIALOG = {
                    IDLE = T("PIP_UI_Button_Trade_Dialog_Idle", {
                        GUID = "0eaee1d5-4389-4363-897e-aa6d1f864cf2",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Trade_Dialog_Highlighted", {
                        GUID = "4283f049-d9f9-48e9-a9f0-dcb6088a331a",
                    }),
                    PRESSED = T("PIP_UI_Button_Trade_Dialog_Pressed", {
                        GUID = "8feece66-8f95-4259-8af8-ef8510c116fb",
                    }),
                }
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
            BLUE_DOS1 = {
                IDLE = T("PIP_UI_Button_Blue_DOS1_Idle", {
                    GUID = "86d9bf96-cc3c-4ade-8f9d-3ff57461b176",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Blue_DOS1_Highlighted", {
                    GUID = "7e31e43e-0fa1-4cbe-b5b2-0684d65f90eb",
                }),
                PRESSED = T("PIP_UI_Button_Blue_DOS1_Pressed", {
                    GUID = "f04a8483-19df-42ca-929b-45265e3c04aa",
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
                },
                MEDIUM_TEXTURED = {
                    IDLE = T("PIP_UI_Button_Green_Medium_Textured_Idle", {
                        GUID = "ada9a49e-7a5e-429e-b113-a96dfa0e63b5",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Green_Medium_Textured_Highlighted", {
                        GUID = "210bf8f3-7ab4-4e49-a9e5-7396460aad4a",
                    }),
                    PRESSED = T("PIP_UI_Button_Green_Medium_Textured_Pressed", {
                        GUID = "3cf0ed75-7f46-4147-9540-2761cea346bf",
                    }),
                    DISABLED = T("PIP_UI_Button_Green_Medium_Textured_Disabled", {
                        GUID = "39ccab76-01ee-4cbc-9061-1e5995ac956d",
                    }),
                },
                SMALL_TEXTURED = {
                    IDLE = T("PIP_UI_Button_Green_Small_Textured_Idle", {
                        GUID = "616f6cbe-86a2-4a23-becc-8c5c0156a676",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Green_Small_Textured_Highlighted", {
                        GUID = "e25d3193-3c64-44a9-8b45-f9afb6ffa87b",
                    }),
                    PRESSED = T("PIP_UI_Button_Green_Small_Textured_Pressed", {
                        GUID = "43b6eda4-6c34-40da-987d-50baad92a290",
                    }),
                    DISABLED = T("PIP_UI_Button_Green_Small_Textured_Disabled", {
                        GUID = "6396e49f-063d-408d-b6d4-5224697ca917",
                    }),
                },
                -- TODO import the rest of its textures
                MICRO_SMOOTH = {
                    IDLE = T("PIP_UI_Button_Green_MicroSmooth_Idle", {
                        GUID = "7b1aa5dc-1c48-4fa0-9fca-5ff90bac4927",
                    }),
                },
            },
            YELLOW = {
                DECORATED = {
                    IDLE = T("PIP_UI_Button_Yellow_Decorated_Idle", {
                        GUID = "0eacc141-5b47-4f74-85a3-0b9498ad7308",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Yellow_Decorated_Highlighted", {
                        GUID = "f881aa44-6db6-4705-aa34-ce6ec2e0fc57",
                    }),
                    PRESSED = T("PIP_UI_Button_Yellow_Decorated_Pressed", {
                        GUID = "b6e48453-89fc-4fa7-b590-16ea004fac27",
                    }),
                },
            },
            COMBO_BOX = {
                IDLE = T("PIP_UI_Button_ComboBox_Idle", {
                    GUID = "02d29401-cf6f-4f38-8b69-7212d3d0caf4",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_ComboBox_Highlighted", {
                    GUID = "1125c2f8-9846-49bb-b0de-d1d9afa09d60",
                }),
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
                SIMPLE = {
                    IDLE = T("PIP_UI_Button_Close_Simple_Idle", {
                        GUID = "938cd77b-5d75-4656-a1ce-c3e1d7352fda",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Close_Simple_Highlighted", {
                        GUID = "6c5f535b-ebe1-4d14-bd28-bf1c0d9dd131",
                    }),
                    PRESSED = T("PIP_UI_Button_Close_Simple_Pressed", {
                        GUID = "4e6e044d-d5a1-42d5-a217-7fedf3d65029",
                    }),
                },
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
                LONG = {
                    IDLE = T("PIP_UI_Button_Brown_Long_Idle", {
                        GUID = "40f576d8-877a-447c-9bda-1f6ae0e80a33",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Brown_Long_Highlighted", {
                        GUID = "5e7b41eb-1aed-4d36-a505-3ab164fcfccd",
                    }),
                    PRESSED = T("PIP_UI_Button_Brown_Long_Pressed", {
                        GUID = "203a0a4a-f7fa-4860-9c13-70c472e1b67c",
                    }),
                    DISABLED = T("PIP_UI_Button_Brown_Long_Disabled", {
                        GUID = "b77fcc92-e21f-4974-9a3f-8250105bd126",
                    }),
                },
                MICRO = {
                    IDLE = T("PIP_UI_Button_Brown_Micro_Idle", {
                        GUID = "1328e64c-9dbe-4dfc-b2da-6726db5b35d4",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Brown_Micro_Highlighted", {
                        GUID = "87a14c13-2907-47a0-bcb9-f631098fa160",
                    }),
                    PRESSED = T("PIP_UI_Button_Brown_Micro_Pressed", {
                        GUID = "0a72e8d9-41e2-4914-84ba-afd35a816694",
                    }),
                    DISABLED = T("PIP_UI_Button_Brown_Micro_Disabled", {
                        GUID = "4e79c7c1-03ee-48de-af50-e1607a2ece98",
                    }),
                },
            },
            COUNTER = {
                GREEN = {
                    INCREMENT = {
                        IDLE = T("PIP_UI_Button_Increase_Green_Idle", {
                            GUID = "458fe207-cd2a-4772-85cf-092c3e3ff64b",
                        }),
                    },
                    DECREMENT = {
                        IDLE = T("PIP_UI_Button_Subtract_Green_Idle", {
                            GUID = "0b729a0d-b748-4d13-93c3-097f6449aa41",
                        }),
                    },
                },
                WHITE = {
                    INCREMENT = {
                        IDLE = T("PIP_UI_Button_Increase_White_Idle", {
                            GUID = "fb0fb13a-57e1-4251-83d8-43071669358d",
                        }),
                    },
                    DECREMENT = {
                        IDLE = T("PIP_UI_Button_Subtract_White_Idle", {
                            GUID = "ecbe1c14-30ea-41b5-bab9-3c589b372bf4",
                        }),
                    }
                },
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
                SMALL_STONE = {
                    INCREMENT = {
                        IDLE = T("PIP_UI_Button_Add_Stone_Small_Idle", {
                            GUID = "e8ba24e5-0c3b-4cf4-839c-328db78fa474",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Add_Stone_Small_Highlighted", {
                            GUID = "35f55e35-7841-430a-a3ed-0980ccdcbd01",
                        }),
                        PRESSED = T("PIP_UI_Button_Add_Stone_Small_Pressed", {
                            GUID = "88c49b11-8d9e-4f76-a09e-e9340ed57cf2",
                        }),
                    },
                    DECREMENT = {
                        IDLE = T("PIP_UI_Button_Subtract_Stone_Small_Idle", {
                            GUID = "6484d905-2a11-4a47-a777-105c4f02e0d9",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Subtract_Stone_Small_Highlighted", {
                            GUID = "094ace97-d155-4204-8f6c-a610744bb57a",
                        }),
                        PRESSED = T("PIP_UI_Button_Subtract_Stone_Small_Pressed", {
                            GUID = "6623a6a0-af82-429c-a9c6-1b2b5b408c68",
                        }),
                    },
                },
                CHARACTER_SHEET = {
                    INCREMENT = {
                        IDLE = T("PIP_UI_Button_Increase_CharacterSheet_Idle", {
                            GUID = "99ff12d9-c604-4ac1-83d8-db870a77f41f",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Increase_CharacterSheet_Highlighted", {
                            GUID = "f74f995c-0819-4cca-b045-6d1cdcf2e436",
                        }),
                        PRESSED = T("PIP_UI_Button_Increase_CharacterSheet_Pressed", {
                            GUID = "f8ffc452-3df8-4d28-92bf-85d901bd781c",
                        }),
                    },
                    DECREMENT = {
                        IDLE = T("PIP_UI_Button_Subtract_CharacterSheet_Idle", {
                            GUID = "f9e16f5a-dbdc-4e21-9f55-655ae5d6a86d",
                        }),
                        HIGHLIGHTED = T("PIP_UI_Button_Subtract_CharacterSheet_Highlighted", {
                            GUID = "c96efd8e-55a9-43f8-9dd6-502f9461c54a",
                        }),
                        PRESSED = T("PIP_UI_Button_Subtract_CharacterSheet_Pressed", {
                            GUID = "b233ea17-47f0-430c-982e-c7bd83492ce3",
                        }),
                    },
                },
            },
            TABS = {
                CHARACTER_SHEET = {
                    IDLE = T("PIP_UI_Button_Tab_CharacterSheet_Idle", {
                        GUID = "676f3d34-91ee-4012-b309-25c75f5c1a0a",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Tab_CharacterSheet_Highlighted", {
                        GUID = "1fde7cfa-c990-4a40-b607-298ad5191d76",
                    }),
                    PRESSED = T("PIP_UI_Button_Tab_CharacterSheet_Pressed", {
                        GUID = "6c4b77fa-f996-4d8a-bbf6-30cee0c17c42",
                    }),
                    DISABLED = T("PIP_UI_Button_Tab_CharacterSheet_Disabled", {
                        GUID = "4f01216b-3eaf-4346-8a74-b42b888a29d4",
                    }),
                },
                CHARACTER_SHEET_WIDE = {
                    IDLE = T("PIP_UI_Button_Tab_CharacterSheet_Wide_Idle", {
                        GUID = "6458ac3c-5690-40bd-b837-7c0442cc2279",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Tab_CharacterSheet_Wide_Highlighted", {
                        GUID = "abfa3dac-5502-4c0c-b0c0-1c3f2d61cc58",
                    }),
                    PRESSED = T("PIP_UI_Button_Tab_CharacterSheet_Wide_Pressed", {
                        GUID = "ba8cca5a-376e-4405-98f7-f4bc627b6bd9",
                    }),
                    DISABLED = T("PIP_UI_Button_Tab_CharacterSheet_Wide_Disabled", {
                        GUID = "d1d1a0c0-3dc1-4153-94e1-09e19fb12431",
                    }),
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
                    DISABLED = T("PIP_UI_Button_Notch_Disabled", {
                        GUID = "911e0d6b-9432-4c02-a14c-26b0d217d96d",
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
                DISABLED = T("PIP_UI_Button_Transparent_Disabled", {
                    GUID = "9ff15069-4dcc-42c3-9e48-7ef1342f8cbe",
                }),
            },
            TRANSPARENT_MEDIUM = {
                IDLE = T("PIP_UI_Button_Transparent_Medium_Idle", {
                    GUID = "814a8a95-83ca-49ff-ab1e-5422ead1a663",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Transparent_Medium_Highlighted", {
                    GUID = "3915f2ba-c427-4c09-9ac9-4f4882c03d61",
                }),
                PRESSED = T("PIP_UI_Button_Transparent_Medium_Pressed", {
                    GUID = "2baa3fa3-d41e-4ac3-87d3-ee207fdfd1e5",
                }),
            },
            TRANSPARENT_LONG = {
                DISABLED = T("PIP_UI_Button_Transparent_Long_Disabled", {
                    GUID = "9ad78cbd-877c-4f22-8864-83e786293b53",
                }),
                HIGHLIGHTED = T("PIP_UI_Button_Transparent_Long_Highlighted", {
                    GUID = "9a56f5c2-0715-45cc-904c-65a431dd1c87",
                }),
                IDLE = T("PIP_UI_Button_Transparent_Long_Idle", {
                    GUID = "089bf0fe-db86-4e79-8ef5-7be53779776c",
                }),
                PRESSED = T("PIP_UI_Button_Transparent_Long_Pressed", {
                    GUID = "f0a9af65-25ab-4b16-a3ba-84c5a0235b52",
                }),
            },
            TRANSPARENT_LARGE_DARK = {
                HIGHLIGHTED = T("PIP_UI_Button_Transparent_LargeDark_Highlighted", {
                    GUID = "e05a9d73-426f-4d3e-8c7c-f934ffbb8fae",
                }),
                IDLE = T("PIP_UI_Button_Transparent_LargeDark_Idle", {
                    GUID = "5e45d73b-f5b2-459d-a229-cc8c753ea37a",
                }),
                PRESSED = T("PIP_UI_Button_Transparent_LargeDark_Pressed", {
                    GUID = "1f27d74e-9d9b-45ce-9ed4-4edb62329a1c",
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
                    DISABLED = T("PIP_UI_Button_Red_Large_Disabled", {
                        GUID = "634b1104-dbdf-46a8-9023-a12ee6c97624",
                    }),
                },
                LARGE_WITH_ARROWS = {
                    IDLE = T("PIP_UI_Button_Red_LargeWithArrows_Idle", {
                        GUID = "9f68b093-6e36-4202-8a54-6d314161916b",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Red_LargeWithArrows_Highlighted", {
                        GUID = "01319879-c5ea-40e7-acb5-9c807abcf1fb",
                    }),
                    PRESSED = T("PIP_UI_Button_Red_LargeWithArrows_Pressed", {
                        GUID = "d7313550-fe78-4f09-ac59-1c717e3850b5",
                    }),
                    DISABLED = T("PIP_UI_Button_Red_LargeWithArrows_Disabled", {
                        GUID = "4c240309-2003-41bf-a19a-d0d5c7f8232c",
                    }),
                },
                MEDIUM = {
                    IDLE = T("PIP_UI_Button_Red_Medium_Idle", {
                        GUID = "67c374cf-d058-4088-8e17-b7fe40c8c9ea",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_Red_Medium_Highlighted", {
                        GUID = "40b918d6-e2a2-4bb1-8c54-8535e2006dc4",
                    }),
                    PRESSED = T("PIP_UI_Button_Red_Medium_Pressed", {
                        GUID = "01443586-4456-4116-be58-02651890ee40",
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
            WHITE = {
                MEDIUM = {
                    IDLE = T("PIP_UI_Button_White_Medium_Idle", {
                        GUID = "22dea120-d5f0-4079-be3d-67fb098e939a",
                    }),
                    HIGHLIGHTED = T("PIP_UI_Button_White_Medium_Highlighted", {
                        GUID = "4b672dfa-1705-4640-a06f-a06c8079c687",
                    }),
                    PRESSED = T("PIP_UI_Button_White_Medium_Pressed", {
                        GUID = "4a476b74-979f-4e42-b779-125579296c0d",
                    }),
                },
            },
        },
        STATE_BUTTONS = {
            ARMOR = {
                ACTIVE_IDLE = T("PIP_UI_StateButton_Armor_Active_Idle", {
                    GUID = "4dd8aee9-3d3d-4833-a98c-09396a5a1a5e",
                }),
                INACTIVE_IDLE = T("PIP_UI_StateButton_Armor_Inactive_Idle", {
                    GUID = "47b13a7c-ac2c-4ade-adce-5ec2eb46f73c",
                }),
            },
            ARMOR_BORDERLESS = {
                ACTIVE_IDLE = T("PIP_UI_StateButton_Armor_Borderless_Active_Idle", {
                    GUID = "0629fa58-bab0-4803-b47b-7680f41c847e",
                }),
                INACTIVE_IDLE = T("PIP_UI_StateButton_Armor_Borderless_Inactive_Idle", {
                    GUID = "52e15ca2-cab9-4e2b-a501-9cfbc2226c37",
                }),
            },
            HELMET = {
                ACTIVE_IDLE = T("PIP_UI_StateButton_Helmet_Active_Idle", {
                    GUID = "66a0c68b-c8b3-4ca5-ad2b-78c1506a59f7",
                }),
                ACTIVE_HIGHLIGHTED = T("PIP_UI_StateButton_Helmet_Active_Highlighted", {
                    GUID = "f4ee630e-b285-4589-baf2-5ee2c2e4f9e4",
                }),
                ACTIVE_PRESSED = T("PIP_UI_StateButton_Helmet_Active_Pressed", {
                    GUID = "0bc55824-f225-46a5-ab64-c2b7a15bf786",
                }),
                INACTIVE_IDLE = T("PIP_UI_StateButton_Helmet_Inactive_Idle", {
                    GUID = "c9767386-1bfb-46f5-b51a-f322adee7b54",
                }),
                INACTIVE_HIGHLIGHTED = T("PIP_UI_StateButton_Helmet_Inactive_Highlighted", {
                    GUID = "9f539c9c-db0a-4052-9c9b-e03af511a4dd",
                }),
                INACTIVE_PRESSED = T("PIP_UI_StateButton_Helmet_Inactive_Pressed", {
                    GUID = "bb98f623-6b42-4b9b-8e84-716c4531f88c",
                }),
            },
            HELMET_BORDERLESS = {
                INACTIVE_IDLE = T("PIP_UI_StateButton_Helmet_Borderless_Inactive_Idle", {
                    GUID = "d0bd88be-c48c-493e-916a-b5792db7dee6",
                }),
                ACTIVE_IDLE = T("PIP_UI_StateButton_Helmet_Borderless_Active_Idle", {
                    GUID = "5acaffb2-2598-439d-97fa-1a7ae1e73ecd",
                }),
            },
            GENDER = {
                MALE = {
                    BORDERLESS = {
                        INACTIVE_IDLE = T("PIP_UI_StateButton_Gender_Male_Inactive_Idle", {
                            GUID = "e446c971-7e98-4b9e-9f5c-61d625ebac49",
                        }),
                        ACTIVE_IDLE = T("PIP_UI_StateButton_Gender_Male_Active_Idle", {
                            GUID = "33112059-7466-490e-95bd-87418c6f5b4b",
                        }),
                    },
                },
                FEMALE = {
                    BORDERLESS = {
                        INACTIVE_IDLE = T("PIP_UI_StateButton_Gender_Female_Inactive_Idle", {
                            GUID = "7439e473-6925-4705-a931-9a3a96183059",
                        }),
                        ACTIVE_IDLE = T("PIP_UI_StateButton_Gender_Female_Active_Idle", {
                            GUID = "68942707-7804-4706-ac09-f35b357d6bda",
                        }),
                    },
                },
            },
            BROWN_SIMPLE = {
                INACTIVE = {
                    IDLE = T("PIP_UI_StateButton_Brown_Inactive_Idle", {
                        GUID = "b7f6e1d0-a44e-4fb7-aad1-6794afcf52e9",
                    }),
                    HIGHLIGHTED = T("PIP_UI_StateButton_Brown_Inactive_Highlighted", {
                        GUID = "5246c4fa-9054-4f8c-ba02-fe4c91c5d056",
                    }),
                    PRESSED = T("PIP_UI_StateButton_Brown_Inactive_Pressed", {
                        GUID = "cc4abf3f-ae7f-47f0-8f4f-2a883325bbcc",
                    }),
                },
                ACTIVE = {
                    IDLE = T("PIP_UI_StateButton_Brown_Active_Idle", {
                        GUID = "e6bc7323-b18c-4599-91d4-7b34da0c94d3",
                    }),
                    HIGHLIGHTED = T("PIP_UI_StateButton_Brown_Active_Highlighted", {
                        GUID = "31cd6106-a8e8-4be0-bd32-751d8ee2e4e2",
                    }),
                    PRESSED = T("PIP_UI_StateButton_Brown_Active_Pressed", {
                        GUID = "8a75c6b6-56a9-4f88-a554-78d684bb1191",
                    }),
                },
            },
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
            BLACK_OUTLINE = T("PIP_UI_Frame_BlackOutline", {
                GUID = "80b407c0-57c5-4260-b675-8fe541672a89",
            }),
            PORTRAIT = {
                BLACK_OUTLINE = T("PIP_UI_Frame_Portrait_BlackOutline", {
                    GUID = "857e1332-063f-4d2c-8105-ff4877954c6f",
                }),
                BROWN = T("PIP_UI_Frame_Portrait_Brown", {
                    GUID = "5f6ae2a9-b815-4f07-909a-8dfc9ffcbd40",
                }),
                GOLDEN = T("PIP_UI_Frame_Portrait_Golden", {
                    GUID = "f77e3f35-314d-46cc-9440-500839a808dd",
                }),
                GOLDEN_HIGHLIGHTED = T("PIP_UI_Frame_Slot_Fancy_Gold_Highlighted", {
                    GUID = "b345e0ff-f3ad-466a-886d-73eb934bb334",
                }),
                SILVER = T("PIP_UI_Frame_Slot_Fancy_Silver", {
                    GUID = "eb313b8b-54b8-4d08-b716-45b4f4dfea8e",
                }),
                SILVER_HIGHLIGHTED = T("PIP_UI_Frame_Slot_Fancy_Silver_Highlighted", {
                    GUID = "45f65faf-d7ab-4295-8c06-e8ea56cd5e65",
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
                    DARK_RED = T("PIP_UI_Frame_Portrait_Combat_DarkRed", {
                        GUID = "1e108c6a-6d16-49ab-896e-8e6f1df65169",
                    }),
                    GRAY = T("PIP_UI_Frame_Portrait_Combat_Gray", {
                        GUID = "88912b8e-0094-4c3d-ba50-96df2b83b6a9",
                    }),
                    RED = T("PIP_UI_Frame_Portrait_Combat_Red", {
                        GUID = "6c86877b-6d7d-4b9b-897d-f6854aa8c1d4",
                    }),
                },
                HEX = {
                    BRONZE = T("PIP_UI_Frame_HexPortrait_Bronze", {
                        GUID = "1cbc8c37-bc7c-4b06-b811-7e8b4d18c79f",
                    }),
                    GOLD = T("PIP_UI_Frame_HexPortrait_Gold", {
                        GUID = "c3c4cf5c-3cba-4f34-8955-d46a639388c8",
                    }),
                },
            },
            COLORED_NOTIFICATION = {
                DARK_RED = T("PIP_UI_Frame_ColoredNotification_DarkRed", {
                    GUID = "929c08ab-1682-4f8c-b17a-4da1fc24db29",
                }),
            },
            DARK_LABEL = T("PIP_UI_Frame_DarkLabel", {
                GUID = "9261ce84-4254-4c36-bef9-504a876f4b81",
            }),
            ENTRIES = {
                DARK = T("PIP_UI_Frame_Entry_Dark", {
                    GUID = "de09b187-935c-44d1-8b0b-81979519b106",
                }),
                GRAY = T("PIP_UI_Frame_Entry_Transparent_WithRightMargin", {
                    GUID = "f4a62d9d-0d0a-4306-a77e-0c445fbae54e",
                }),
            },
            EQUIPMENT_SLOTS = {
                AMULET = T("PIP_UI_Frame_Slot_Amulet", {
                    GUID = "179baed8-5f67-47d4-ae1c-f055839979ed",
                }),
                BELT = T("PIP_UI_Frame_Slot_Belt", {
                    GUID = "cd969162-1987-4e25-bfe4-6bede67c9b0b",
                }),
                BOOTS = T("PIP_UI_Frame_Slot_Boots", {
                    GUID = "eef80e64-7cd6-49e6-86e6-12a97e7cc499",
                }),
                BREAST = T("PIP_UI_Frame_Slot_Breast", {
                    GUID = "2cbb55a0-557e-4e50-bc85-aaa99a717c47",
                }),
                GLOVES = T("PIP_UI_Frame_Slot_Gloves", {
                    GUID = "09232c62-69eb-49f1-beaf-3b8143d7750c",
                }),
                HELMET = T("PIP_UI_Frame_Slot_Helmet", {
                    GUID = "45ea09a4-ab60-4be1-8862-9efab72c0460",
                }),
                LEGGINGS = T("PIP_UI_Frame_Slot_Leggings", {
                    GUID = "60b3003b-7ef8-499c-a81a-674d51fc7801",
                }),
                MAINHAND = T("PIP_UI_Frame_Slot_Mainhand", {
                    GUID = "356511e7-02b0-4c32-8f84-46ef112d868f",
                }),
                OFFHAND = T("PIP_UI_Frame_Slot_Offhand", {
                    GUID = "12d6cf8b-9eb4-407d-90bd-3421356888e9",
                }),
                RING_1 = T("PIP_UI_Frame_Slot_Ring_1", {
                    GUID = "40624267-0803-412a-9e0b-dc9c174a86e5",
                }),
                RING_2 = T("PIP_UI_Frame_Slot_Ring_2", {
                    GUID = "46c2809d-d7cb-4b0c-9b37-4a95c0d844fd",
                }),
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
                    SIMPLE = T("PIP_UI_Frame_Slot_Add_Simple", {
                        GUID = "75af7dda-8564-4af8-b791-ba0a91939058",
                    }),
                },
                FANCY_LARGE = T("PIP_UI_Frame_Slot_Fancy_Large", {
                    GUID = "12db1336-372c-4272-a422-c3fc99add409",
                }),
                FANCY_GOLD = T("PIP_UI_Frame_Slot_Fancy_Gold", {
                    GUID = "c7e1451c-ad81-4e17-a874-b4330d106632",
                }),
            },
            STATUS = T("PIP_UI_Frame_Status", {
                GUID = "d3c9259b-df2e-4941-8a80-dd9082e0e9d0",
            }),
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
            RECTANGLES = {
                TINY = T("PIP_UI_Frame_Rectangle_Tiny", {
                    GUID = "e0a47972-cbfa-4329-82bb-6c8bebb3ae19",
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
            ATTRIBUTES = T("PIP_UI_Panel_Attributes", {
                GUID = "c5c618ed-2bad-4677-a692-e8a4b68ca077",
            }),
            CONNECTIVITY = T("PIP_UI_Panel_Connectivity", {
                GUID = "66c99298-6b56-4edc-b764-939459a8b3a6",
            }),
            CLIPBOARD = T("PIP_UI_Panel_Clipboard", {
                GUID = "de3756f6-4566-4be0-95b5-32f2b7706d68",
            }),
            CLIPBOARD_ADORNED = T("PIP_UI_Panel_Clipboard_Adorned", {
                GUID = "bcb610d0-14ec-4313-96d3-a1a2af88da49",
            }),
            CLIPBOARD_THIN = T("PIP_UI_Panel_Clipboard_Thin", {
                GUID = "26fd3bae-5456-460e-be02-ae6782ab99ef",
            }),
            CLIPBOARD_SMALL = T("PIP_UI_Panel_Clipboard_Small", {
                GUID = "6624ce8e-5acd-4e3d-99e9-8efb8d34c3dc",
            }),
            CLIPBOARD_HEADERED = T("PIP_UI_Panel_Clipboard_Headered", {
                GUID = "67f908d0-04bf-4718-9c43-543f9f8fe4cb",
            }),
            CLIPBOARD_HEADERED_WITH_ICON_NO_PAPER = T("PIP_UI_Panel_Clipboard_Headered_WithIcon_NoPaper", {
                GUID = "b5a70373-276d-496f-bdd3-5b3744698add",
            }),
            CLIPBOARD_LARGE = T("PIP_UI_Panel_Clipboard_Large", {
                GUID = "c416e67c-339b-4527-937a-cc96cf9c93e8",
            }),
            CLIPBOARD_FEEDBACK = T("PIP_UI_Panel_FeedbackClipboard", {
                GUID = "9eacfe27-708f-4745-9743-7c660025507b",
            }),
            CLIPBOARD_FEEDBACK_COMMENT = T("PIP_UI_Panel_FeedbackComment", {
                GUID = "f58f5f8b-6f85-4936-b297-95e6f9fcddbd",
            }),
            DUAL_ROW = T("PIP_UI_Panel_DualRow", {
                GUID = "d285a27c-3010-45fd-806e-b13a0f2dcb33",
            }),
            DIALOGUE = T("PIP_UI_Panel_Dialog", {
                GUID = "cf771be5-106b-47d3-9358-bcffefc970fd",
            }),
            DIALOGUE_CONTROLLER = T("PIP_UI_Panel_Dialogue_Controller", {
                GUID = "3ec1cc16-61f4-4a55-a4cb-fb0b994d6ad4",
            }),
            DIPLOMACY = T("PIP_UI_Panel_Diplomacy", {
                GUID = "bc439685-4da4-4e38-b1d3-745840f6dd96",
            }),
            DOS1_EXAMINE = T("PIP_UI_Panel_Examine_DOS1", {
                GUID = "d1bd56a1-faed-45b4-870c-4310cbfd7672",
            }),
            FEEDBACK = T("PIP_UI_Panel_Feedback", {
                GUID = "15535d46-9d26-45fb-91c1-55c58853699a",
            }),
            FLIPBOOK = T("PIP_UI_Panel_Flipbook", {
                GUID = "274e6019-38b3-4616-bbe1-f92b654978ff",
            }),
            GAME_MENU = T("PIP_UI_Panel_GameMenu", {
                GUID = "1efd93d3-0a2b-4af9-ae71-7809907a5ac0",
            }),
            PROFILE = T("PIP_UI_Panel_Profile", {
                GUID = "e68d62f5-9782-4647-bd14-2b37f9a83df7",
            }),
            LEGEND = T("PIP_UI_Panel_Legend", {
                GUID = "696b5050-16ff-4d7a-a151-f80d3a8065f5",
            }),
            LEGEND_SMALL = T("PIP_UI_Panel_Legend_Small", {
                GUID = "77ca66a4-b593-4383-b69e-3a937f6152ac",
            }),
            LOAD = T("PIP_UI_Panel_Load", {
                GUID = "a0a41f2c-4c87-438d-b5f7-ce82e0b1abfb",
            }),
            MODS = T("PIP_UI_Panel_Mods", {
                GUID = "2f3f8d74-c893-43ec-8af7-23131a028ab6",
            }),
            MODS_CONTROLLER = T("PIP_UI_Panel_Mods_Controller", {
                GUID = "d8bc3ed7-4564-4759-90b8-f92c2d864adc",
            }),
            REWARDS_CONTROLLER = T("PIP_UI_Panel_Reward_Controller", {
                GUID = "16ed65db-3642-4671-bcc4-f67d00f4f026",
            }),
            NOTE_CONTROLLER = T("PIP_UI_Panel_Note_Controller", {
                GUID = "6cc944eb-92e2-46d8-a360-f4454b0be1da",
            }),
            SKILLBOOK = T("PIP_UI_Panel_SkillBook", {
                GUID = "e4214879-bc18-4e72-94eb-fb3617d8d212",
            }),
            SKILLBOOK_KBM = T("PIP_UI_Panel_SkillBook_KBM", {
                GUID = "c7d39a28-c306-4d33-bbb1-0be6b2f53733",
            }),
            SETTINGS_LEFT = T("PIP_UI_Panel_Settings_Left", {
                GUID = "61e915dd-0a76-4496-ae30-864ff029bd98",
            }),
            SETTINGS_RIGHT = T("PIP_UI_Panel_Settings_Right", {
                GUID = "dfcaa132-be0d-4f01-9c0e-4a35abcbe5e6",
            }),
            LIST = T("PIP_UI_Panel_List", {
                GUID = "f3e1f7d5-bb6e-464f-b51d-ebe4adfd247a",
            }),
            MESSAGE_BOX_INPUT = T("PIP_UI_Panel_MessageBox_Input", {
                GUID = "9905eb39-449e-4cf9-a326-ef7f429f8c1e",
            }),
            MESSAGE_BOX = T("PIP_UI_Panel_MessageBox_Message", {
                GUID = "2bb72a22-8e00-48d2-b2b1-d5fece3e381f",
            }),
            TALL_PAGE = T("PIP_UI_Panel_TallPage", {
                GUID = "21cffdb1-3eb3-49c5-9584-48b8d4536d59",
            }),
            TALL_PAGE_SCROLLABLE = T("PIP_UI_Panel_TallPage_Scrollable", {
                GUID = "0cb61cd9-ca1a-4a75-9e9c-d11cf211d119",
            }),
            TALL_PAGE_SPLIT = T("PIP_UI_Panel_TallPage_Split", {
                GUID = "fdcba990-0c20-416c-a8ec-921d78640c64",
            }),
            TALL_PAGE_PORTRAIT = T("PIP_UI_Panel_TallWithPortrait", {
                GUID = "7b677843-dde9-49b2-bd13-8b7d78575ff1",
            }),
            PAGE_OUTLINE = T("PIP_UI_Panel_PageOutline", {
                GUID = "4e82a6ee-a0e6-4734-b2d7-bc18f78ec008",
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
        SLICED = {
            CONTEXT_MENU = {
                TOP = T("PIP_UI_Sliced_ContextMenu_Top", {
                    GUID = "8172ba51-9d43-4972-9d98-5d8deb79dbc0",
                }),
                CENTER = T("PIP_UI_Sliced_ContextMenu_Center", {
                    GUID = "033c7b00-cf5a-43c3-ab80-3312d7e6e9bc",
                }),
                BOTTOM = T("PIP_UI_Sliced_ContextMenu_Bottom", {
                    GUID = "169b776a-a91c-452f-a8f6-c150ef34ca7d",
                }),
            },
            MESSAGES = {
                BLACK = {
                    LEFT = T("PIP_UI_Sliced_Message_Black_Left", {
                        GUID = "3ff77668-16f1-410e-8617-452d83b94734",
                    }),
                    CENTER = T("PIP_UI_Sliced_Message_Black_Center", {
                        GUID = "94d24937-5f27-4338-81cc-b784d9cbc265",
                    }),
                    RIGHT = T("PIP_UI_Sliced_Message_Black_Right", {
                        GUID = "ec89795b-5a76-48c1-a95d-49786091cdee",
                    }),
                },
                WHITE = {
                    LEFT = T("PIP_UI_Sliced_Message_White_Left", {
                        GUID = "3e227be3-bb19-4c95-870e-c5a94a907fa5",
                    }),
                    CENTER = T("PIP_UI_Sliced_Message_White_Center", {
                        GUID = "99988cc0-9637-4eb1-8fc1-480efea6d47c",
                    }),
                    RIGHT = T("PIP_UI_Sliced_Message_White_Right", {
                        GUID = "e6e65926-67bc-4833-97d0-8ce194d00d84",
                    }),
                },
            },
            AZTEC_SQUIGGLES = {
                BOTTOM = T("PIP_UI_Sliced_Squiggles_Bottom", {
                    GUID = "ea14dccf-2637-4a54-a665-88961ad25188",
                }),
                BOTTOM_LEFT = T("PIP_UI_Sliced_Squiggles_BottomLeft", {
                    GUID = "a44a488c-28e3-4995-8d90-012dbc319256",
                }),
                BOTTOM_RIGHT = T("PIP_UI_Sliced_Squiggles_BottomRight", {
                    GUID = "1c6e6a53-d9b3-4acc-8916-b32ad07f9c97",
                }),
                CENTER = T("PIP_UI_Sliced_Squiggles_Center", {
                    GUID = "de88e8ed-5047-4acc-af2c-db82ed497aec",
                }),
                LEFT = T("PIP_UI_Sliced_Squiggles_Left", {
                    GUID = "09844d91-2178-496a-82ff-afb4c8331989",
                }),
                RIGHT = T("PIP_UI_Sliced_Squiggles_Right", {
                    GUID = "52f8335f-7ff4-47c6-bfca-c91dcc372a44",
                }),
                TOP = T("PIP_UI_Sliced_Squiggles_Top", {
                    GUID = "9fd930db-da28-4148-8381-0c1c01570d06",
                }),
                TOP_LEFT = T("PIP_UI_Sliced_Squiggles_TopLeft", {
                    GUID = "a3825428-6cc4-4e06-aaef-c5fce44068e8",
                }),
                TOP_RIGHT = T("PIP_UI_Sliced_Squiggles_TopRight", {
                    GUID = "99f32503-af5a-4c54-af49-265863778a05",
                }),
            },
            SIMPLE_TOOLTIP = {
                BOTTOM = T("PIP_UI_Sliced_SimpleTooltip_Bottom", {
                    GUID = "44cf82fc-990b-44b1-97e1-77e4923b0a44",
                }),
                BOTTOM_LEFT = T("PIP_UI_Sliced_SimpleTooltip_BottomLeft", {
                    GUID = "3557faba-23d6-4dc9-96b8-ba8c4d90f011",
                }),
                BOTTOM_RIGHT = T("PIP_UI_Sliced_SimpleTooltip_BottomRight", {
                    GUID = "dd629681-b964-48eb-a2d0-35ee9aed30a3",
                }),
                CENTER = T("PIP_UI_Sliced_SimpleTooltip_Center", {
                    GUID = "a80255df-10de-4750-9d70-13917a0011d8",
                }),
                LEFT = T("PIP_UI_Sliced_SimpleTooltip_Left", {
                    GUID = "ce7d00a2-215b-4801-934a-5d54baaf5220",
                }),
                RIGHT = T("PIP_UI_Sliced_SimpleTooltip_Right", {
                    GUID = "35fc76ff-9a5b-4da1-a5c4-762f85def456",
                }),
                TOP = T("PIP_UI_Sliced_SimpleTooltip_Top", {
                    GUID = "99632658-1002-4603-b793-0b639f80fae3",
                }),
                TOP_LEFT = T("PIP_UI_Sliced_SimpleTooltip_TopLeft", {
                    GUID = "28629f1e-a275-40f9-b529-920ee4d88f3e",
                }),
                TOP_RIGHT = T("PIP_UI_Sliced_SimpleTooltip_TopRight", {
                    GUID = "adab85eb-3708-4fe4-9ca0-3ad4c5a57877",
                }),
            },
            SHADOWS = {
                HORIZONTAL = {
                    CENTER = T("PIP_UI_Sliced_HorizontalShadow_Center", {
                        GUID = "1f3ba3b4-1e8f-44f0-8cad-cf2533b6d08f",
                    }),
                    LEFT = T("PIP_UI_Sliced_HorizontalShadow_Left", {
                        GUID = "c70ed0bb-25ab-487c-b5af-1d395be0909a",
                    }),
                    RIGHT = T("PIP_UI_Sliced_HorizontalShadow_Right", {
                        GUID = "a972c571-ea15-42ea-a579-1d65854aded9",
                    }),
                }
            }
        },
        INPUT = {
            CONTROLLER = {
                XBOX = {
                    A_BUTTON = T("PIP_UI_Input_Controller_A", {
                        GUID = "ebc7f23d-8701-4fe0-840a-d2d4d1f4928d",
                    }),
                    B_BUTTON = T("PIP_UI_Input_Controller_B", {
                        GUID = "02f7d859-8187-4737-8368-9765e8c20103",
                    }),
                    LEFT_BUTTON = T("PIP_UI_Input_Controller_LeftButton", {
                        GUID = "583eb3b6-e33b-45b4-b518-b226bfeafa98",
                    }),
                    LEFT_TRIGGER = T("PIP_UI_Input_Controller_LeftTrigger", {
                        GUID = "56f03ad1-901c-4bb1-b720-484de829844b",
                    }),
                    RIGHT_BUTTON = T("PIP_UI_Input_Controller_RightButton", {
                        GUID = "9a8a9db7-13f1-49ef-ba47-36b22fed0de0",
                    }),
                    RIGHT_TRIGGER = T("PIP_UI_Input_Controller_RightTrigger", {
                        GUID = "ede1cb73-049f-47a9-8e57-22e07092faef",
                    }),
                    SELECT = T("PIP_UI_Input_Controller_Select", {
                        GUID = "e9f64ac9-9601-4050-a0b9-3ea21b1f95a8",
                    }),
                    X_BUTTON = T("PIP_UI_Input_Controller_X", {
                        GUID = "e8c2aecf-c29f-46b4-80ad-977cd8e15382",
                    }),
                    Y_BUTTON = T("PIP_UI_Input_Controller_Y", {
                        GUID = "417f1f7d-66bc-4efc-b059-fd5a1fac5710",
                    }),
                    START = T("PIP_UI_Input_Controller_Start", {
                        GUID = "889e8257-a18e-4307-b0f3-a4fbf23d1d69",
                    }),
                    RIGHT_STICK = {
                        NEUTRAL = T("PIP_UI_Input_Controller_RightStick", {
                            GUID = "9ba0b9ae-6980-4756-baa2-bc80fda060fc",
                        }),
                        DOWN = T("PIP_UI_Input_Controller_RightStick_Down", {
                            GUID = "35cc44ba-c8fd-4d05-b692-17a36a5f30ff",
                        }),
                        HORIZONTAL = T("PIP_UI_Input_Controller_RightStick_Horizontal", {
                            GUID = "e17a547d-051b-4945-8403-828775c807f2",
                        }),
                        LEFT = T("PIP_UI_Input_Controller_RightStick_Left", {
                            GUID = "e0f9f2b8-40cf-4fdf-8803-46e1b573cee9",
                        }),
                        PRESS = T("PIP_UI_Input_Controller_RightStick_Press", {
                            GUID = "109a38d6-d7db-495e-81e0-3b7df77869d0",
                        }),
                        RIGHT = T("PIP_UI_Input_Controller_RightStick_Right", {
                            GUID = "76963b60-cc1c-4ba7-a061-a6cb41b3a98c",
                        }),
                        UP = T("PIP_UI_Input_Controller_RightStick_Up", {
                            GUID = "b25e78ea-1dcb-47e9-ba42-d753cd2cc2c3",
                        }),
                        VERTICAL = T("PIP_UI_Input_Controller_RightStick_Vertical", {
                            GUID = "878c59bc-98c9-4a26-a366-2bef7db5cbc7",
                        }),
                    },
                    LEFT_STICK = {
                        NEUTRAL = T("PIP_UI_Input_Controller_LeftStick", {
                            GUID = "0010c412-5f85-4d32-ba33-f29d8a832bf4",
                        }),
                        DOWN = T("PIP_UI_Input_Controller_LeftStick_Down", {
                            GUID = "3234d9df-188b-4967-b498-b3295f713e6f",
                        }),
                        HORIZONTAL = T("PIP_UI_Input_Controller_LeftStick_Horizontal", {
                            GUID = "e7ea1214-783a-4967-8d78-7d0c1db95683",
                        }),
                        LEFT = T("PIP_UI_Input_Controller_LeftStick_Left", {
                            GUID = "3239d57c-ee63-4931-94b7-5fd2c6155120",
                        }),
                        PRESS = T("PIP_UI_Input_Controller_LeftStick_Press", {
                            GUID = "3ec1ee37-3641-43df-96c1-9dcca6c174ea",
                        }),
                        RIGHT = T("PIP_UI_Input_Controller_LeftStick_Right", {
                            GUID = "703067f4-8211-48fd-8233-2a7d6f2c9f76",
                        }),
                        UP = T("PIP_UI_Input_Controller_LeftStick_Up", {
                            GUID = "616e7298-2532-49e3-8ffb-5a1c05f02052",
                        }),
                        VERTICAL = T("PIP_UI_Input_Controller_LeftStick_Vertical", {
                            GUID = "4fb70643-bb3c-4d44-b6df-3174ef670c6f",
                        }),
                    },
                    DPAD = {
                        NEUTRAL = T("PIP_UI_Input_Controller_DPad", {
                            GUID = "9c7e7d8d-5055-4d8a-9c62-5762a5189564",
                        }),
                        DOWN = T("PIP_UI_Input_Controller_DPad_Down", {
                            GUID = "95edafa3-a9e2-4389-8512-0e5b0a0be4ca",
                        }),
                        HORIZONTAL = T("PIP_UI_Input_Controller_DPad_Horizontal", {
                            GUID = "27051165-d22d-4967-8c6a-256efd35f763",
                        }),
                        LEFT = T("PIP_UI_Input_Controller_DPad_Left", {
                            GUID = "dc3c6dae-ecec-4118-b59e-ef9e243ce455",
                        }),
                        RIGHT = T("PIP_UI_Input_Controller_DPad_Right", {
                            GUID = "bbef708b-7bba-4608-94d2-d49a9c9d1672",
                        }),
                        UP = T("PIP_UI_Input_Controller_DPad_Up", {
                            GUID = "8cf19060-d0e1-4fa2-8178-1916a507dfb8",
                        }),
                        VERTICAL = T("PIP_UI_Input_Controller_DPad_Vertical", {
                            GUID = "e9df2c03-5384-4163-9012-56750efc5116",
                        }),
                    },
                },
            },
        },
        MISC = {
            ARROW_BLACK = T("PIP_UI_Misc_Arrow_Black", {
                GUID = "e2e21ff0-06ef-45b7-98fb-870cabc8fd6f",
            }),
            ARROW_WHITE = T("PIP_UI_Misc_Arrow_White", {
                GUID = "d2e6126c-7a3d-41d7-92e0-fd45296692f3",
            }),
            ARROW_SHORT_LEFT = T("PIP_UI_Misc_ShortArrow_Left", {
                GUID = "a6d5dca3-2f95-4e74-8140-c8d989c0ffe5",
            }),
            DVD = T("PIP_UI_Misc_DVD", {
                GUID = "081d2dce-c13c-44d3-8a32-ad2070068f8a",
            }),
            GLOW_BEIGE = T("PIP_UI_Misc_Glow_Beige", {
                GUID = "6acd5391-65db-4042-a3e7-61c0eac8684f",
            }),
            GLOW_ORANGE = T("PIP_UI_Misc_Glow_Orange", {
                GUID = "93e01819-35a1-4d4c-8b16-947fe331355c",
            }),
            GLOW_WHITE = T("PIP_UI_Misc_White", {
                GUID = "c3473e90-30b2-47a1-b424-93a1464a72c5",
            }),
            BACKLIGHT = T("PIP_UI_Misc_Backlight", {
                GUID = "94a54564-ba49-4c4c-97ef-c843bc9f15c9",
            }),
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
            VERTICAL_HOLDER = T("PIP_UI_Misc_VerticalHolder", {
                GUID = "fcd1393d-2009-4a4c-897a-ffcf6bd82955",
            }),
            SHADOW_BACKDROP = T("PIP_UI_Misc_ShadowBackdrop", {
                GUID = "42ed2237-4f0b-4b54-8bc1-894d3af95a3c",
            }),
            SHADOW_BOTTOM = T("PIP_UI_Misc_Shadow_Bottom", {
                GUID = "514fe1d1-6d27-447a-8919-1a778aaa9475",
            }),
            UNKNOWN_MAP = T("PIP_UI_Misc_UnknownMap", {
                GUID = "0750ca35-e268-4cdd-b14d-daba7fa245c1",
            }),
            ORANGE_HALO = T("PIP_UI_Misc_OrangeHalo", {
                GUID = "c1eb5800-afd0-4345-8180-375d35cde8bb",
            }),
            SWIRL = T("PIP_UI_Misc_Swirl", {
                GUID = "84bacaf2-7d99-46f8-a0b1-3cad107662be",
            }),
            SWIRLING_STAR = T("PIP_UI_Misc_SwirlingStar", {
                GUID = "df081eac-306b-46fe-b9d8-47cd33248f05",
            }),
            LOADING_FLOWER = {
                CARDINAL = T("PIP_UI_Misc_LoadingFlower_Cardinal", {
                    GUID = "018a1540-7cfa-418e-877a-e187f84a786c",
                }),
                DIAGONAL = T("PIP_UI_Misc_LoadingFlower_Diagonal", {
                    GUID = "d28c9893-db80-48e2-b425-b226374bc7a8",
                }),
            },
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
    TranslatedStrings = {},
}
Epip.RegisterFeature("GenericUITextures", Textures)