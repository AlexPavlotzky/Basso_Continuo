import MuseScore 3.0
import QtQuick 2.9

MuseScore {
    menuPath: "Plugins.Add Figured Bass"
    description: "Add Figured Bass."
    version: "0.1"

    Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            title = qsTr("Add Figured Bass");
            categoryCode = qsTr("PitDad Tools");
        }
    }

    function getSelectedNotesPitchs() {
        var selectedNotes = []
        var selection = curScore.selection
        if (selection) {
            for (var i = 0; i < selection.elements.length; i++) {
                var element = selection.elements[i]
                if (element.type === Element.NOTE) {
                    selectedNotes.push(element.pitch)
                }
            }
        }
        return selectedNotes
    }

    function detectTonics(notes) {
        var firstTonic = parseInt(notes[0]); // Parse the first tonic to an integer
        var tonics = [firstTonic];
        var indexTonics = 0;

        // Search tonics based on authentic cadences (V-I)
        for (var i = 1; i < notes.length - 1; i++) { // Iterates up to and including the penultimate element
            if ((parseInt(notes[i]) + 5 === parseInt(notes[i + 1]) || parseInt(notes[i]) - parseInt(notes[i + 1]) === 7) 
            && (parseInt(notes[i+1]) !== parseInt(tonics[indexTonics]) + 12
            && parseInt(notes[i+1]) !== parseInt(tonics[indexTonics]) - 12) 
            && (parseInt(notes[i]) !== parseInt(tonics[indexTonics]))) { // Found authentic cadence (V-I)
                var tonic = parseInt(notes[i + 1]);
                tonics.push(tonic); // Add the new tonic to the tonic array
                indexTonics += 1;
            }
        }
        // Filter consecutive duplicate tonics
        var filteredTonics = [tonics[0]]; // Initialize the array with the first tonic
        for (var j = 1; j < tonics.length; j++) {
            if (tonics[j] !== tonics[j - 1]) {
                filteredTonics.push(tonics[j]);
            }
        }

        return filteredTonics;
    }

    function calculateNumberSemitones(notes) {
        var tonics = detectTonics(notes); // Get all tonics found
        var numberofsemitones = {};
        var i = 0;

        // Go through all the tonics found
        for (var t = 0; t < tonics.length; t++) {
            var tonic = tonics[t];
            var nextTonic = tonics[t+1];
            var semitonesArray = [];

            for (i; i < notes.length; i++) {
                var distanceofsemitones = parseInt(notes[i]) - parseInt(tonic);
                semitonesArray.push(distanceofsemitones.toString());
                if (parseInt(notes[i+1]) === parseInt(nextTonic) && 
                (parseInt(notes[i]) + 5 === parseInt(notes[i + 1]) || parseInt(notes[i]) - parseInt(notes[i + 1]) === 7)) {
                    i += 1;
                    break;
                }
            }

            numberofsemitones[t.toString()] = semitonesArray; // Use the index string as the key in the object
        }

        return numberofsemitones;
    }

    function calculateModes(numberofsemitones) {
        var modes = [];

        for (var key in numberofsemitones) {
            var semitones = numberofsemitones[key];
            var mode = "";

            for (var i = 0; i < semitones.length; i++) {
                var semitone = parseInt(semitones[i]);

                if (semitone === 4 || semitone === 9 || semitone === -1 || semitone === -3) {
                    mode = "major";
                    break;
                } else if (semitone === 3 || semitone === 8 || semitone === 10 || semitone === -2 || semitone === -4) {
                    mode = "minor";
                    break;
                } else {
                    mode = "indefinite";
                }
            }

            modes.push(mode);
        }

        return modes;
    }

    function calculateDegrees(numberofsemitones, notes) {
        const degreesMapping = { "-12": -8, "-10": -7, "-9": -6, "-8": -6, "-7": -5, "-5": -4, "-4": -3, "-3": -3, "-2": -2,
            "-1": -2, "0": 1, "2": 2, "3": 3, "4": 3, "5": 4, "7": 5, "8": 6, "9": 6, "10": 7, "11": 7, "12": 8, "14": 9,
            "15": 10, "16": 10, "17": 11, "18": 18, "19": 18 };

        var degrees = {};
        var tonics = detectTonics(notes);

        for (var tonic in numberofsemitones) {
            if (numberofsemitones.hasOwnProperty(tonic)) {
                var degreesArray = numberofsemitones[tonic].map(degree => degreesMapping[degree.toString()] || degree);
                degrees[tonic] = degreesArray;
            }
        }

        var degreesArray = [];
        for (var key in degrees) {
            degreesArray.push(degrees[key]);
        }

        if (tonics.length > 1) {
            for (let i = 0; i < degreesArray.length; i++) {
                let subArray = degreesArray[i];
                subArray[subArray.length - 1] = 5;
            }
        }

        return degreesArray;
    }

    function calculateIntervalDirections(notes) {
        var directions = [];
        directions.push("fundamental");
        for (var i = 0; i < notes.length - 1; i++) {
            if (notes[i] < notes[i + 1]) {
                directions.push("ascends");
            } else if (notes[i] > notes[i + 1]) {
                directions.push("descends");
            } else {
                directions.push("unison");
            }
        }
        return directions;
    }

    function addFiguredBass(grades, directionsofintervals, modes) {
        var cifrasarray = [];
        var directions = directionsofintervals;
        var indexDirection = 0;
        var figuredbass = {
            major: ['835', '634', '683', '563', '358', '36', '3b56', '34#6', '624', '836', '643'],
            minor: ['358', '34#6','836', '635', '58#3', '363', 'b563', '463', '#462', '683', '43#6'],
            indefinite: ['358', 'NNN', 'NNN', '635', '58#3', 'NNN', 'NNN', 'NNN', 'NNN', 'NNN', 'NNN']
        };

        var degreesMap = {
            "-8": 0,
            "-7": { ascends: 1, descends: 10, unison: -1 },
            "-6": { ascends: 2, descends: 9, unison: -1 },
            "-5": { ascends: 3, descends: 3, unison: -1 },
            "-4": 4,
            "-3": { ascends: 5, descends: 5, unison: -1 },
            "-2": { ascends: 5, descends: 6, unison: -1 },
            "1": 0,
            "2": { ascends: 1, descends: 10, unison: -1 },
            "3": { ascends: 2, descends: 9, unison: -1 },
            "4": { ascends: 3, descends: 3, unison: -1 },
            "5": 4,
            "6": { ascends: 5, descends: 7, unison: -1 },
            "7": { ascends: 5, descends: 5, unison: -1 },
            "8": 0,
            "9": { ascends: 1, descends: 10, unison: -1 },
            "10": { ascends: 2, descends: 9, unison: -1 },
            "11":  { ascends: 3, descends: 3, unison: -1 }
        };

        for (var i = 0; i < modes.length; i++) {
            var mode = modes[i];
            var figureIndex = [];
            var grade = grades[i];

            for (var t = 0; t < grade.length; t++) {
                var gradeKey = grade[t].toString();
                var direction = directions[indexDirection];

                if (degreesMap.hasOwnProperty(gradeKey)) {
                    var index = degreesMap[gradeKey];
                    if (typeof index === 'object') {
                        if (direction === "unison") {
                            figureIndex.push(figureIndex[indexDirection-1]);
                            indexDirection += 1;
                        } else {
                            index = index[direction];
                            figureIndex.push(figuredbass[mode][index]);
                            indexDirection += 1;
                        }
                    } else {
                        figureIndex.push(figuredbass[mode][index]);
                        indexDirection += 1;
                    }
                }
            }

            cifrasarray = cifrasarray.concat(figureIndex);
        }

        return cifrasarray;
    }

    function replaceSymbols(array) {
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
            } else if (array[i] == '34#6' || array[i] == '634' || array[i] == '4#63' 
                || array[i] == '643' || array[i] == '43#6' || array[i] == 'b364' || array[i] == '463') {
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
        var selectedNotes = getSelectedNotesPitchs()
        if (selectedNotes.length === 0) {
            return
        }

        var numberSemitones = calculateNumberSemitones(selectedNotes)
        var grades = calculateDegrees(numberSemitones, selectedNotes)
        var modes = calculateModes(numberSemitones)
        var intervalDirections = calculateIntervalDirections(selectedNotes)
        var figuredBass = addFiguredBass(grades, intervalDirections, modes)
        var symbols = replaceSymbols(figuredBass)

        var selectedElement = curScore.selection.elements[0]
        var segment = selectedElement.parent
        
        while (segment && segment.type != Element.SEGMENT) { 
            segment = segment.parent
        }

        if (segment) {
            var tick = segment.tick
            var cursor = curScore.newCursor()
            cursor.rewindToTick(tick)
            cursor.track = selectedElement.track

            while (cursor && cursor.element && symbols.length > 0) {
                if (cursor.element.type == Element.CHORD) {
                    var cifrado = newElement(Element.FIGURED_BASS)
                    cifrado.text = symbols[0]
                    
                    curScore.startCmd()
                    cursor.add(cifrado)
                    curScore.endCmd()

                    symbols.shift()
                }
                cursor.next()
            }
        }
    }
}
