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

    function dandrieu(numberofsemitones, directionsofintervals, mode) {
        var cifrasarray = [];

        var ascendingdictionary = {
            grade1: ['835', '583', '358'],
            grade2: ['634', '46b3', '34#6'],
            grade3: ['683', '368', '836'],
            grade4: ['563', '356', '635'],
            grade5: ['358', '835', '58#3'],
            grade6: ['36', 'b63b6', '363'],
            grade7: ['3b56', '63b5', 'b563'],
            grade8: ['35', '583', '358']
        };

        var descendingdictionary = {
            grade1: ['835', '583', '358'],
            grade2: ['643', 'b364', '43#6'],
            grade3: ['836', '368', '683'],
            grade4: ['624', '246', '#462'],
            grade5: ['358', '835', '58#3'],
            grade6: ['34#6', '634', '463'],
            grade7: ['36', '636', '363'],
            grade8: ['35', '583', '358']
        };
        
        for (var i = 0; i < numberofsemitones.length; i++) {
            if (mode == "major") {
                if (numberofsemitones[i] == 0 && directionsofintervals[i] == "fundamental") {
                    cifrasarray.push(ascendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "fundamental") {
                    cifrasarray.push(ascendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 2 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade2[0]);
                } else if (numberofsemitones[i] == 2 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade2[0]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] == 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade2[0]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] == 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(descendingdictionary.grade2[0]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] !== 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] !== 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(descendingdictionary.grade1[0]);
                } else if (numberofsemitones[i] == 4 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade3[0]);
                } else if (numberofsemitones[i] == 4 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade3[0]);
                } else if (numberofsemitones[i] == 4 && directionsofintervals [i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade3[0]);
                } else if (numberofsemitones[i] == 4 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade3[0]);
                } else if (numberofsemitones[i] == 5 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade4[0]);
                } else if (numberofsemitones[i] == 5 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade4[0]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] == 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade4[0]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] == 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(descendingdictionary.grade4[0]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] !== 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade4[0]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] !== 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(ascendingdictionary.grade4[0]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade5[0]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade5[0]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[0]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[0]);
                } else if (numberofsemitones[i] == 9 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == 9 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == 9 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == 9 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade8[0]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade8[0]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade8[0]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade8[0]);
                } else if (numberofsemitones[i] == -1 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == -1 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == -1 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == -1 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade7[0]);
                } else if (numberofsemitones[i] == -3 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == -3 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == -3 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == -3 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade6[0]);
                } else if (numberofsemitones[i] == -5 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[0]);
                } else if (numberofsemitones[i] == -5 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[0]);
                }
            } else if (mode == "minor") {
                if (numberofsemitones[i] == 0 && directionsofintervals[i] == "fundamental") {
                    cifrasarray.push(ascendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "fundamental") {
                    cifrasarray.push(ascendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 0 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 2 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade2[2]);
                } else if (numberofsemitones[i] == 2 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade2[2]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] == 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade2[2]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] == 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(descendingdictionary.grade2[2]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] !== 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 2 && numberofsemitones[i-1] !== 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(descendingdictionary.grade1[2]);
                } else if (numberofsemitones[i] == 3 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade3[2]);
                } else if (numberofsemitones[i] == 3 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade3[2]);
                } else if (numberofsemitones[i] == 3 && directionsofintervals [i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade3[2]);
                } else if (numberofsemitones[i] == 3 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade3[2]);
                } else if (numberofsemitones[i] == 5 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade4[2]);
                } else if (numberofsemitones[i] == 5 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade4[2]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] == 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade4[2]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] == 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(descendingdictionary.grade4[2]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] !== 4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade4[2]);
                } else if (numberofsemitones[i] == 5 && numberofsemitones[i+1] !== 4 && directionsofintervals[i] == "unísono") {
                    cifrasarray.push(ascendingdictionary.grade4[2]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade5[2]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade5[2]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[2]);
                } else if (numberofsemitones[i] == 7 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[2]);
                } else if (numberofsemitones[i] == 8 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == 8 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == 8 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == 8 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == 10 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 10 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 10 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 10 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 11 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade8[2]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade8[2]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade8[2]);
                } else if (numberofsemitones[i] == 12 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade8[2]);
                } else if (numberofsemitones[i] == -2 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == -2 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == -2 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == -2 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade7[2]);
                } else if (numberofsemitones[i] == -4 && directionsofintervals[i] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == -4 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "asciende") {
                    cifrasarray.push(ascendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == -4 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == -4 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(ascendingdictionary.grade6[2]);
                } else if (numberofsemitones[i] == -6 && directionsofintervals[i] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[2]);
                } else if (numberofsemitones[i] == -6 && directionsofintervals[i] == "unísono" && directionsofintervals[i-1] == "desciende") {
                    cifrasarray.push(descendingdictionary.grade5[2]);
                }
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
        var mode = calculatemode(numberSemitones)
        var directionsIntervals = intervalDirection(notesArray)
        var cifrasofnotesArray = dandrieu(numberSemitones, directionsIntervals, mode)
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
