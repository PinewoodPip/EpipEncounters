import uuid, re
from tkinter import *
from tkinter import filedialog
import os, subprocess
from pathlib import Path
from generic_convert_to_dds import Converter

PROJECT_FOLDER_PATH = r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Public\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356"
TEMPLATE_LSX_PATH = "texture_importer_template.lsx"

TEXTURE_SOURCE_PATH = r"C:\Users\Usuario\Pictures\Art\Epip\Generic Textures"
TEXTURE_OUTPUT_PATH = r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Public\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Assets\Textures\UI"

NAME_REGEX = re.compile(".+/(.+)\.dds$")
CONTENT_PATH = r"C:\Program Files (x86)\Steam\steamapps\common\Divinity Original Sin 2\DefEd\Data\Public\EpipEncounters_7d32cb52-1cfd-4526-9b84-db4867bf9356\Content\[PAK]_UI"

class Importer:
    def import_texture(texturePath:str, name:str=None):
        ddsPath = Path(texturePath)
        guid = uuid.uuid4()
        relativePath = None
        
        # Convert image to DDS first if necessary, and move to mod texture directory
        if ddsPath.suffix != ".dds":
            converter = Converter(TEXTURE_SOURCE_PATH, TEXTURE_OUTPUT_PATH)
            ddsPath = Path(converter.process_image(str(ddsPath)))

        relativePath = ddsPath.relative_to(PROJECT_FOLDER_PATH)
            
        if name == None:
            name = ddsPath.stem

        outputPath = Path(CONTENT_PATH).joinpath(str(guid) + ".lsf")

        lsx = open(TEMPLATE_LSX_PATH, "r").read()
        lsx = lsx.format(guid, relativePath, name)
        with open("temp.lsx", "w") as f:
            f.write(lsx)

        subprocess.call(["C:/Users/Usuario/Documents/ActualDocuments/Tools/LsLib_v1.15.15/Tools/divine.exe", "-g", "dos2de", "-i", "lsx", "-o", "lsf", "-a", "convert-resource", "-s", os.path.join(os.getcwd(), "temp.lsx"), "-d", outputPath, "-l", "off"])

        print(name, str(guid))

class ViewModel:
    def __init__(self):
        self.current_files = []

    def selectFiles(self):
        files = filedialog.askopenfilenames()
        self.current_files = files

    def import_textures(self):
        for path in self.current_files:
            Importer.import_texture(path)

class View:
    def __init__(self):
        self.window = Tk()
        self.vm = ViewModel()

        Button(self.window, text="Select Textures (.dds)", command=self.selectFiles).pack()

        self.files_label = Label(self.window, text="No files selected")
        self.files_label.pack()

        Button(self.window, text="Import", command=self.import_textures).pack()

        self.window.title("Texture Importer")
        self.window.geometry("800x400")
        self.window.mainloop()

    def selectFiles(self):
        self.vm.selectFiles()
        self.refresh()

    def import_textures(self):
        self.vm.import_textures()

    def refresh(self):
        self.files_label.config(text="\n".join(self.vm.current_files))
        pass

View()