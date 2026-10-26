/// A complete example event in the import format. Organisers copy it, change the
/// words, and import it as a draft. It shows each kind of puzzle.
///
/// Dates are text like 2026-11-20T18:00. Colours are hex. Everything except the
/// types is optional; what is missing is listed when the draft is checked.
const eventJsonSample = r'''{
  "name": "Comoara din Sibiu",
  "description": "O vânătoare de comori prin centrul vechi, în echipe de câte 4.",
  "location": "Sibiu",
  "punctDeStart": "Piața Mare, lângă fântână",
  "type": "PUBLIC",
  "startCode": "SIBIU26",
  "dateEvent": "2027-05-15T18:00",
  "dateStartEnrollment": "2027-05-01T09:00",
  "dateDeadlineEnrollment": "2027-05-14T23:59",
  "lungimeTraseu": "3 km",
  "durata": "2 ore",
  "dificultate": "Medie",
  "landingImageUrl": null,
  "taskBackgroundImageUrl": null,
  "missions": [
    {
      "puzzles": [
        {
          "type": "code",
          "code": "1521",
          "indiciu": "Anul se vede deasupra intrării.",
          "components": [
            {
              "type": "text",
              "text": "În ce an a fost construită prima casă din piață?",
              "textColor": "#FFFFFF",
              "fontSize": 20,
              "fontWeight": "bold",
              "textAlign": "center"
            },
            {
              "type": "code",
              "codeLength": 4,
              "inputType": "Separated",
              "capsLock": "Fără",
              "frameBackgroundColor": "#101820",
              "inputBackgroundColor": "#1B2A38",
              "colorBorderInput": "#33FF66",
              "inputCornerRadius": 8
            },
            {
              "type": "button",
              "buttonLabel": "Verifică",
              "buttonColor": "#33FF66",
              "buttonTextColor": "#000000",
              "cornerRadius": 12
            }
          ]
        },
        {
          "type": "geolocation",
          "latitude": 45.7983,
          "longitude": 24.1521,
          "indiciu": "Podul are o legendă despre minciuni.",
          "components": [
            {
              "type": "text",
              "text": "Du-te la Podul Minciunilor.",
              "textColor": "#FFFFFF",
              "fontSize": 18,
              "textAlign": "center"
            }
          ]
        }
      ]
    },
    {
      "puzzles": [
        {
          "type": "imageToUpload",
          "components": [
            {
              "type": "text",
              "text": "Fă o poză de echipă în fața Catedralei. Un organizator o aprobă.",
              "textColor": "#FFFFFF",
              "fontSize": 18,
              "textAlign": "center"
            }
          ]
        }
      ]
    }
  ]
}
''';
