---------------------------------------------
-- TSKs for tags that are visible in the character sheet.
-- These are tags that are marked as "Race", "Gender", "Story", "Profession", or "Origin" in the editor.
---------------------------------------------

---@class CharacterLib.TagResource
---@field NameHandle TranslatedStringHandle
---@field DescriptionHandle TranslatedStringHandle

---@type table<tag, CharacterLib.TagResource>
Character.Tags = {
    ["MALE"] = {
        NameHandle = "he1ef9c7bg93eeg4e18ga47dg06789e864713",
        DescriptionHandle = "h4471f599g3e9dg4b66gbdf7gdfc6886fabab"
    },
    ["FEMALE"] = {
        NameHandle = "hb281b452g0a18g45e0gb87dg11a7c81b0287",
        DescriptionHandle = "h5eed062bg82b4g4939gbe31g9ee4258bc322"
    },
    ["HERO"] = {
        NameHandle = "h21cb499cg4fabg4a37gb3e5g8d0623d82ec1",
        DescriptionHandle = "hbc90ed0egda69g4f9dgba59g63faadc193e0"
    },
    ["VILLAIN"] = {
        NameHandle = "h00ab5fa1gdc92g4802ga797gbdf7360fb4be",
        DescriptionHandle = "hbdf96024g732bg46aag8f39gc67b8087a191"
    },

    -- Race tags
    ["HUMAN"] = {
        NameHandle = "h99219c09gd9a7g4863ga3a2g0b230f8b3425",
        DescriptionHandle = "hd330974ag6af5g41a5g86deg858991e0d7dd"
    },
    ["ELF"] = {
        NameHandle = "h9d08ee2bge501g4a68gb6d3g89abeecd885f",
        DescriptionHandle = "h335cbd1fg8f46g4955ga96bgae2d2afc6f84"
    },
    ["DWARF"] = {
        NameHandle = "h36418453ga178g4f34g970eg80674ef38e9c",
        DescriptionHandle = "h132fbfd8g5bd9g4a41ga6a8g1cdf4ebea42b"
    },
    ["LIZARD"] = {
        NameHandle = "h16f81844g1a16g4af9g8e00gf2161676a3ce",
        DescriptionHandle = "h8f7338ffg1b37g4a77g8448g2337cef53adb"
    },
    ["UNDEAD"] = {
        NameHandle = "heb7f2b40ga0a7g441cg96a3g563ef5b45db8",
        DescriptionHandle = "h0177c648gbbc4g4a90gb032g00fe406456fb"
    },

    -- Character creation tags
    ["BARBARIAN"] = {
        NameHandle = "h9db200ebg9d22g4838g92cag358845c0ae29",
        DescriptionHandle = "hf174794fg01ecg4c69g8a00g79a9f6b4a29e"
    },
    ["JESTER"] = {
        NameHandle = "h396c5c10g12a3g4f54gbcecg90f5dad8dbed",
        DescriptionHandle = "h9cddbebdgfe81g4f93g83d8g72e2536addca"
    },
    ["MYSTIC"] = {
        NameHandle = "h901ae2f4g00feg4e7ag99abg9fd07a463029",
        DescriptionHandle = "hebf0663dg8ab2g49f0ga6b8g2b8b5988515e"
    },
    ["SOLDIER"] = {
        NameHandle = "hf6822f36gff70g43b1g8fccge4ca186c066c",
        DescriptionHandle = "hfed0fce3ge551g4da9gb42eg40768352dfae"
    },
    ["OUTLAW"] = {
        NameHandle = "hf03d1112g66ccg42bdgac7fgd28da344f2f1",
        DescriptionHandle = "h7a5a4758g1abeg4823gb791g29c4168b9d9f"
    },
    ["SCHOLAR"] = {
        NameHandle = "h58bf3925g50f9g4536g9583g66c7e9143ebb",
        DescriptionHandle = "h1ff0196cgc6f8g4db4gbf4cg360de2e208a4"
    },
    ["NOBLE"] = {
        NameHandle = "h48e2e44agb495g43fbgb4c8g52f40a021080",
        DescriptionHandle = "hea1fb2b4g6fb4g4e8dgb65fgb5400d32fb78"
    },

    -- Origins tags
    ["IFAN"] = {
        NameHandle = "h6bf77d65g8f31g468cgad98gddcade9f28e3",
        DescriptionHandle = "hebb4d016g8594g4f5cg8183g81f5b9ead8dd"
    },
    ["RED PRINCE"] = {
        NameHandle = "h702dfeb3gecf9g4acdg9df0gedcaa7a62e38",
        DescriptionHandle = "h814c9e84g2c34g436ag85a9g4c26f0eec97d"
    },
    ["LOHSE"] = {
        NameHandle = "h411a29e8g7109g4025gacfcg57db2429c174",
        DescriptionHandle = "heda4a3e9gc63ag4034g8a70ga35803525fb2"
    },
    ["SEBILLE"] = {
        NameHandle = "h3eb0df3fgdb45g4c53ga74fg7768739f86e2",
        DescriptionHandle = "h1ddd5679g1338g4da1gabbeg738d5744a7aa"
    },
    ["BEAST"] = {
        NameHandle = "hd1ce984fg30cfg4679g8572g5d56d833ae1a",
        DescriptionHandle = "h2a929a23gd22fg4e7cg8f77g454fc8bc30f6"
    },
    ["FANE"] = {
        NameHandle = "h92a537ddgf65ag4bd7g9dd9gb7b31bd169fa",
        DescriptionHandle = "h525ec3d8gca9eg4367ga667g325b819963b9"
    },

    -- Story tags
    ["CHAMPION_FTJ"] = {
        NameHandle = "h7f43963cg49ffg441ag80f1g30c08a4ae92f",
        DescriptionHandle = "ha17a45ccg6929g45eagb7b4gf3dbd10a3dea"
    },
    ["CHAMPION_DW"] = {
        NameHandle = "h081df2f6g50feg4ebbga666g4e99ebdb0c97",
        DescriptionHandle = "h7872e7acgbb4dg453eg8672g2aa066608f60"
    },
    ["THE_ONE"] = {
        NameHandle = "hce32314cg3170g4cc4ga475gbf0992eb4aee",
        DescriptionHandle = "h00b39963g5be1g4c1cgbbe5g455e8d32bf73"
    },
    ["BLOODBOUND"] = {
        NameHandle = "h0c2eb49egd6c8g4adeg85e8g20dc26bfa6b5",
        DescriptionHandle = "hf86fce6eg2675g44b1g94f1gafb9e6b7f684"
    },
    ["ELF-FRIEND"] = {
        NameHandle = "h1297901eg79b4g4176g94c8g25d2306129c4",
        DescriptionHandle = "h46196249gca97g4151gae77gdbae453aa624"
    },
    ["DWARF-FRIEND"] = {
        NameHandle = "hf2d0ef12g3f45g4daeg8ebdgd406df125541",
        DescriptionHandle = "h8560e281g01f0g4d7dg8e29gc5d5606b7629"
    },
    ["GIANT_SLAYER"] = {
        NameHandle = "h4370076bg8006g459dg848fg8119a481bae6",
        DescriptionHandle = "he9447e67gaca3g49e1gb2ddg3ff452801f75"
    },
    ["PROMISED"] = {
        NameHandle = "h0245ba9fgdd52g45c3gae50g5dd20ded3bc0",
        DescriptionHandle = "hab69a8adg0b84g4641gb6c3g2888e26a4a72"
    },
}
