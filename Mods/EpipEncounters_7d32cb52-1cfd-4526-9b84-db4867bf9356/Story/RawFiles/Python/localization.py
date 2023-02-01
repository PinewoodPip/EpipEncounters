import re,os,xml, json
import openpyxl
from openpyxl.utils import get_column_letter
from openpyxl.utils import *
from openpyxl.styles import *
from openpyxl.styles import Alignment
from openpyxl.worksheet import worksheet

TEXTLIB_TRANSLATION_FILE_FORMAT_VERSION = 0

# -----------------
# CLASSES
# -----------------

class TranslatedString:
    def __init__(self, handle, obj):
        self.text = obj["ReferenceText"]
        self.description = obj["ContextDescription"] if "ContextDescription" in obj else ""
        self.translation = obj["TranslatedText"] if "TranslatedText" in obj else ""
        self.key = obj["ReferenceKey"] if "ReferenceKey" in obj else ""
        self.handle = handle
        self.featureID = obj["FeatureID"] if "FeatureID" in obj else ""

class SheetColumn:
    def __init__(self, name, width, locked:bool=True, wrap_text:bool=True, font=None, json_key:str=None):
        self.name = name
        self.width = width
        self.locked = locked
        self.wrap_text = wrap_text
        self.font = font
        self.json_key = json_key

def addSheetRow(column_defs, i, sheet, row, content:str):
    column_def = column_defs[i]
    letter = get_column_letter(i + 1)

    cell = sheet[letter + str(row)]

    sheet.row_dimensions[row].height = Sheet.ROW_HEIGHT
    
    # Set font
    cell.font = column_def.font

    cell.value = content

    # Set alignment
    if column_def.wrap_text:
        cell.alignment = Alignment(wrap_text=True)

    # Unlock cell for editing
    if not column_def.locked:
        cell.protection = Protection(locked=False)

class Sheet:
    ROW_HEIGHT = 30

    def __init__(self, sheet, name):
        self.name = name
        self.sheet = sheet
        self.column_defs = []
        self._initialized = False
        self.filled_rows = 0

        self.sheet.protection.sheet = True

    def addColumnDefinition(self, column:SheetColumn):
        self.column_defs.append(column)

        # Set width
        self.sheet.column_dimensions[get_column_letter(len(self.column_defs))].width = column.width

        # Protection is set when adding cell content instead.

    def append(self, values):
        self.sheet.append(values)

    def addRow(self, values:list):
        # Add the header row
        if not self._initialized:
            self.sheet.append([column.name for column in self.column_defs])

            self._initialized = True

        self.filled_rows = self.filled_rows + 1

        if len(values) != len(self.column_defs):
            raise ValueError("Iterable length mismatch with column defs amount")

        self.sheet.append(values)

        for i in range(len(values)):
            addSheetRow(self.column_defs, i, self.sheet, self.filled_rows + 1, values[i])


class Workbook:
    def __init__(self):
        self.book = openpyxl.Workbook()
        self.sheets = []
        self._initalized = False

    def addSheet(self, name):
        sheet = Sheet(self.book.create_sheet(name), name)
        self.sheets.append(sheet)

        if not self._initalized:
            self.book.remove(self.book["Sheet"]) # TODO maybe don't?
            self._initalized = True

        return sheet

    def save(self, file_name):
        self.book.save(file_name)

class Module:
    COLUMN_DEFINITIONS = [
        SheetColumn("Handle", 10, wrap_text=False, font=Font(color="999999")),
        SheetColumn("Script", 20, wrap_text=False),
        SheetColumn("Original Text", 65, json_key="ReferenceText"),
        SheetColumn("Contextual Info", 40),
        SheetColumn("Translation", 65, locked=False, json_key="TranslatedText"),
        SheetColumn("Translation Notes", 30, locked=False),
        SheetColumn("Translation Author", 30, locked=False),
    ]

    def __init__(self, name):
        self.name = name
        self.translated_strings:dict[str, TranslatedString] = {}

    def addTSK(self, tsk):
        self.translated_strings[tsk.handle] = tsk

    def export(self, book:Workbook, oldBook:openpyxl.Workbook=None, oldSheetName:str=None, oldBookPath:str=None):

        if oldBook == None:
            sheet = book.addSheet(self.name)

            for column_def in Module.COLUMN_DEFINITIONS:
                sheet.addColumnDefinition(column_def)

            for handle,tsk in self.translated_strings.items():
                sheet.addRow([
                    handle,
                    tsk.featureID,
                    tsk.text,
                    tsk.description,
                    tsk.translation, # Translation
                    "", # Translation author - these are not kept within the json, cannot import
                    "", # Translation notes - same case as author
                ])
        else:
            print("Parsing existing sheet")

            oldSheet:worksheet = oldBook.get_sheet_by_name(oldSheetName)

            existingTSKs = set()
            for rowIndex in range(2, oldSheet.max_row + 1):
                handleCell = oldSheet.cell(row=rowIndex, column=1)
                originalTextCell = oldSheet.cell(row=rowIndex, column=3)
                tskData = self.translated_strings[handleCell.value]
                translationCell = oldSheet.cell(row=rowIndex, column=5)

                # Clear translation if original text doesnt match
                if tskData.text != originalTextCell.value:
                    print("Removed outdated translation for " + tskData.handle)
                    translationCell.value = ""

                originalTextCell.value = tskData.text

                existingTSKs.add(tskData.handle)

            # Add new rows
            newRowIndex = len(existingTSKs) + 2
            for key,data in self.translated_strings.items():
                if key not in existingTSKs:
                    print("Adding new TSK " + key)
                    rowData = [
                        data.handle,
                        data.featureID,
                        data.text,
                        data.description,
                        data.translation, # Translation
                        "", # Translation author - these are not kept within the json, cannot import
                        "", # Translation notes - same case as author
                    ]
                    for i in range(len(rowData)):
                        addSheetRow(Module.COLUMN_DEFINITIONS, i, oldSheet, newRowIndex, rowData[i])

                    newRowIndex += 1

            oldBook.save(oldBookPath)


def createSpreadsheet(file_name, output_file_name, existing_sheet_file_name=None, oldSheetName:str=None):
    file = open(file_name, "r")
    localization = json.load(file)

    module = Module(localization["ModTable"])

    for handle,data in localization["TranslatedStrings"].items():
        tsk = TranslatedString(handle, data)

        module.addTSK(tsk)

    oldBook = None
    if existing_sheet_file_name != None:
        oldBook = openpyxl.open(existing_sheet_file_name)
    book = Workbook()
    module.export(book, oldBook, oldSheetName, existing_sheet_file_name)
    
    print("Saving workbook")
    if existing_sheet_file_name == None:
        book.save(output_file_name)

def createTranslationJSON(file_name:str, modTable:str, sheet_name:str, output_filename:str):
    book = openpyxl.load_workbook(file_name)
    sheet = book[sheet_name]

    # module = Module(sheet_name)

    output = {
        "FileFormatVersion": TEXTLIB_TRANSLATION_FILE_FORMAT_VERSION,
        "ModTable": modTable,
        "TranslatedStrings": {},
    }
    tsks = output["TranslatedStrings"]

    for row in range(2, sheet.max_row + 1):
        handle = sheet["A" + str(row)].value
        tsks[handle] = {}
        tsk = tsks[handle]

        for column_index in range(len(Module.COLUMN_DEFINITIONS)):
            column_def = Module.COLUMN_DEFINITIONS[column_index]

            if column_def.json_key:
                cell = sheet[get_column_letter(column_index + 1) + str(row)]
                value = cell.value

                tsk[column_def.json_key] = value

        # erase TSKs with no translation
        handles_to_delete = []
        for handle,data in tsks.items():
            if "TranslatedText" not in data or data["TranslatedText"] == None:
                handles_to_delete.append(handle)

        for handle in handles_to_delete:
            del tsks[handle]

    with open(output_filename, "w") as f:
        f.write(json.dumps(output, indent=2, ensure_ascii=False))

        print("Converted sheet to json")