import MuseScore 3.0
import QtQuick 2.9

MuseScore {
    menuPath: "Plugins.Agregar Bajo cifrado"
    description: "Agregar Bajo cifrado."
    version: "0.1"

    Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Agregar Bajo cifrado");
            categoryCode = qsTr("PitDad Tools");
        }
    }

    function getSelectedNotesPitchs() {
        var selectedNotes = []
        var selection = curScore.selection
        for (var i = 0; i < selection.elements.length; i++) {
            var element = selection.elements[i]
            if (element.type === Element.NOTE) {
                selectedNotes.push(element.pitch)
            }
        }
        return selectedNotes
    }

    function intervalDistance(array, referenceNote) {
        var distances = [];
        for (var i = 0; i < array.length; i++) {
            var distance = array[i] - referenceNote;
            distances.push(distance);
        }
        return distances;
    }

    function calculatemode(array) {
        var mode = "";

        for (var i = 0; i < array.length - 1; i++) {
            if (array[i] == '4' || array[i] == '9' || array[i] == '-1' || array[i] == '-3') {
                mode = "major";
            } else if (array[i] == '3' || array[i] == '8' || array[i] == '10' || array[i] == '-2' || array[i] == '-4') {
                mode = "minor";
            }
        }
        return mode;
    }

    function calculateGrades(array) {
        const gradeMapping = {
            "-12": -8,
            "-10": -7,
            "-9": -6,
            "-8": -6,
            "-7": -5,
            "-5": -4,
            "-4": -3,
            "-3": -3,
            "-2": -2,
            "-1": -2,
            "0": 1,
            "2": 2,
            "3": 3,
            "4": 3,
            "5": 4,
            "7": 5,
            "8": 6,
            "9": 6,
            "10": 7,
            "11": 7,
            "12": 8,
            "14": 9,
            "15": 10,
            "16": 10,
            "17": 11,
            "18": 18,
            "19": 18
        };

        return array.map(grade => gradeMapping[grade.toString()] || grade);
    }

    function intervalDirection(array) {
        var directions = [];
        directions.push("fundamental");
        for (var i = 0; i < array.length - 1; i++) {
            if (array[i] < array[i + 1]) {
                directions.push("asciende");
            } else if (array[i] > array[i + 1]) {
                directions.push("desciende");
            } else {
                directions.push("unísono");
            }
        }
        return directions;
    }

    function dandrieu(grades, directionsofintervals, mode) {
        var cifrasarray = [];
        var figuredbass = {
            major: ['835', '634', '683', '563', '358', '36', '3b56', '35', '34#6', '624', '836', '643'],
            minor: ['358', '34#6','836', '635', '58#3', '363', 'b563', '358', '463', '#462', '683', '43#6']
        };

        var gradeMap = {
            "-4": 4,
            "-3": {
                asciende: 5,
                desciende: 5,
                unisono: -1
            },
            "-2": {
                asciende: 5,
                desciende: 6,
                unisono: -1
            },
            "1": 0,
            "2": {
                asciende: 1,
                desciende: 11,
                unisono: -1
            },
            "3": {
                asciende: 2,
                desciende: 10,
                unisono: -1
            },
            "4": {
                asciende: 3,
                desciende: 3,
                unisono: -1
            },
            "5": 4,
            "6": {
                asciende: 5,
                desciende: 8,
                unisono: -1
            },
            "7": {
                asciende: 5,
                desciende: 5,
                unisono: -1
            },
            "8": 7
        };

        for (var i = 0; i < grades.length; i++) {
            var grade = grades[i];
            var direction = directionsofintervals[i];
            var figureIndex = gradeMap[grade];

            if (typeof figureIndex === 'object') {
                if (direction === "unisono" || (i > 0 && grades[i] === grades[i - 1])) {
                    cifrasarray.push(cifrasarray[cifrasarray.length - 1]);
                } else {
                    figureIndex = figureIndex[direction];
                    cifrasarray.push(figuredbass[mode][figureIndex]);
                }
            } else {
                cifrasarray.push(figuredbass[mode][figureIndex]);
            }
        }

        return cifrasarray;
    }


    function remplacefigures(array) {
        var figuresarray = [];

        var figuresdictionary = {
            figure1: '#',
            figure2: 'b',
            figure3: '2',
            figure4: '6\\',
            figure5: '5\n4',
            figure6: '6',
            figure7: '6\n4',
            figure8: '5/',
            figure9: '7',
            figure10: '6\n3',
            figure11: '',
            figure12: '6\n5'
        };

        for (var i = 0; i < array.length; i++) {
            if (array[i] == '58#3' || array[i] == '#358' || array[i] == '8#35'){
                figuresarray.push(figuresdictionary.figure1);
            } else if (array[i] == '58b3' || array[i] == 'b358' || array[i] == '8b35') {
                figuresarray.push(figuresdictionary.figure2);
            } else if (array[i] == '246' || array[i] == '624' || array[i] == '462') {
                figuresarray.push(figuresdictionary.figure3);
            } else if (array[i] == '34#6' || array[i] == '634' || array[i] == '4#63' || array[i] == '643' || array[i] == '43#6' || array[i] == 'b364' || array[i] == '463') {
                figuresarray.push(figuresdictionary.figure4);
            } else if (array[i] == '458' || array[i] == '854' || array[i] == '485') {
                figuresarray.push(figuresdictionary.figure5);
            } else if (array[i] == '368' || array[i] == '836' || array[i] == '683') {
                figuresarray.push(figuresdictionary.figure6);
            } else if (array[i] == '468' || array[i] == '846' || array[i] == '684') {
                figuresarray.push(figuresdictionary.figure7);
            } else if (array[i] == '3b56' || array[i] == '63b5' || array[i] == 'b563') {
                figuresarray.push(figuresdictionary.figure8);
            } else if (array[i] == '357' || array[i] == '735' || array[i] == '573') {
                figuresarray.push(figuresdictionary.figure9);
            } else if (array[i] == '363' || array[i] == 'b63b6' || array[i] == '636' || array[i] == '36') {
                figuresarray.push(figuresdictionary.figure10);
            } else if (array[i] == '358' || array[i] == '583' || array[i] == '835' || array[i] == '35' || array[i] == '53') {
                figuresarray.push(figuresdictionary.figure11);
            } else if (array[i] == '635' || array[i] == '356' || array[i] == '563') {
                figuresarray.push(figuresdictionary.figure12);
            }
        }
        return figuresarray;
    }

    onRun: {
        var selectedElement = curScore.selection.elements[0]
        var segment = selectedElement.parent
        
        var referenceNote = getSelectedNotesPitchs()[0]
        var notesArray = getSelectedNotesPitchs()
        var numberSemitones = intervalDistance(notesArray, referenceNote)
        var modes = calculatemode(numberSemitones)
        var grades = calculateGrades(numberSemitones)
        var directionsIntervals = intervalDirection(notesArray)
        var cifrasofnotesArray = dandrieu(grades, directionsIntervals, modes)
        var bassocontinuo = remplacefigures(cifrasofnotesArray)
        
        while (segment && segment.type != Element.SEGMENT) { 
            segment = segment.parent
        }

        if (segment) {
            var tick = segment.tick
            var cursor = curScore.newCursor()
            cursor.rewindToTick(tick)
            cursor.track = selectedElement.track

            while (cursor && cursor.element && bassocontinuo.length > 0) {
                if (cursor.element.type == Element.CHORD) {
                    var cifrado = newElement(Element.FIGURED_BASS)
                    cifrado.text = bassocontinuo[0]
                    
                    curScore.startCmd()
                    cursor.add(cifrado)
                    curScore.endCmd()

                    bassocontinuo.shift()
                }
                cursor.next()
            }
        }
    }
}
