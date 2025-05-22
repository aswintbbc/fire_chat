import 'package:fire_chat/share_html_to_pdf_widget.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HtmlToPdfScreen(),
    );
  }
}

class HtmlToPdfScreen extends StatelessWidget {
  final String htmlUrl = 'https://google.com';

  const HtmlToPdfScreen({super.key});

  Future<String?> _downloadAndPrintHtmlAsPdf(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(htmlUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load HTML. Status code: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  Future<void> _makePdf(String htmlContent) async {
    await Printing.layoutPdf(
      onLayout: (format) async {
        return await Printing.convertHtml(
          format: format,
          html: htmlContent,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HTML to PDF')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final htmlContent = await _downloadAndPrintHtmlAsPdf(context);
                await _makePdf(htmlContent!);
              },
              child: Text('Download PDF'),
            ),
            ShareHtmlToPdfWidget(
              htmlContent: htmlContent,
              filename: 'meal_plan.pdf',
            ),
          ],
        ),
      ),
    );
  }

  final String htmlContent = '''
   <!DOCTYPE html>
<html lang="en">

  <head>
    <meta charset="UTF-8">
    <title>Meal Plan - Fitreat Couple</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 36px;
      }

      .header,
      .footer {
        text-align: center;
      }

      .company-logo {
        float: left;
        width: 25%;
      }

      .meal-table {
        border-collapse: collapse;
        width: 100%;
        font-size: 12px;
      }

      .meal-table th,
      .meal-table td {
        border: 1px solid #000;
        padding: 5px 10px;
        text-align: left;
      }

      .meal-table th {
        text-transform: uppercase;
        font-weight: bold;
        font-size: 13px;
      }


    </style>
  </head>

  <body>

    <table style="width: 100%; border-collapse: collapse; font-family: Arial, sans-serif;margin-bottom:28px;">
      <tr>
        <!-- Left Section -->
        <td style="width: 50%; font-weight: 400; font-size: 30px;color:#383D00;">
          Meal Plan
        </td>

        <!-- Right Details -->
        <td style="width: 50%; text-align: right; font-size: 13px;">
         <img src="https://liveapp.fitreatcouple.com/assets/admin/media/logos/logo_with_name.png" style="width:25em;">
        </td>
      </tr>
    </table>

    <p style="font-size:13px; width: max-content;border: 0.5px solid #000000;margin-bottom:0;line-height:20px;padding:10px 20px 10px 8px;">Client:<span style="font-weight:600;">Ajmal Muhammed</span></p>
    <table class="meal-table">
      <tbody>
        <tr>
          <td>
            <p style="color:#000000;font-size: 10px;font-weight:400;line-height:20px;margin-bottom:0;">Instruction From Nutritionist:</p>
            <p style="color: #000000;font-size: 16px;line-height:16px;padding-top:10px;margin-top:0;">Try your best to stick to the meal timings and portion sizes I've indicated. This helps regulate your blood sugar and keeps you feeling energized throughout the day. Don't forget to drink plenty of water! Aim for at least eight glasses a day, and more if you're exercising.</p>
          </td>
        </tr>
        </tbody>
    </table>
    <table class="meal-table" style="margin-top:24px;">
      <thead>
        <tr>
          <th style="font-size:12px;font-weight:600; width: max-content;border: 0.5px solid #000000;margin-bottom:0;border-bottom:none;line-height:20px;background-color: #DADC55;min-width: 175px;max-width:175px;height: 28px;">Detox Water&nbsp;-&nbsp;<span>6 AM</span></th>
        </tr>
        <tr>
          <th  style="min-width: 175px;max-width: 175px;">Meal</th>
          <th>Macros Info</th>
          <th>Instruction</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Black raisin water (Soak 10 number of raisin in 1 glass water) </td>
          <td>Calorie: 13 Kcal CHO: 3.1 gm Protein: 0.1 gm Fat: 0.0 gm</td>
          <td>Refreshing detox water is a great way to hydrate and support your body's natural detoxification</td>
        </tr>
        <tr>
          <td>Black raisin water (Soak 10 number of raisin in 1 glass water) </td>
          <td>Calorie: 13 Kcal CHO: 3.1 gm Protein: 0.1 gm Fat: 0.0 gm</td>
          <td>Refreshing detox water is a great way to hydrate and support your body's natural detoxification</td>
        </tr>
        </tbody>
    </table>
    <table class="meal-table" style="margin-top:24px;">
      <thead>
        <tr>
          <th style="font-size:12px;font-weight:600; width: max-content;border: 0.5px solid #000000;margin-bottom:0;border-bottom:none;line-height:20px;background-color: #DADC55;min-width: 175px;max-width:175px;height: 28px;">Breakfast&nbsp;-&nbsp;<span>7:30 AM - 8:30 AM</span></th>
        </tr>
        <tr>
          <th style="min-width: 175px;max-width: 175px;">Meal</th>
          <th>Macros Info</th>
          <th>Instruction</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Black raisin water (Soak 10 number of raisin in 1 glass water) </td>
          <td>Calorie: 13 Kcal CHO: 3.1 gm Protein: 0.1 gm Fat: 0.0 gm</td>
          <td>Refreshing detox water is a great way to hydrate and support your body's natural detoxification</td>
        </tr>
        <tr>
          <td>Black raisin water (Soak 10 number of raisin in 1 glass water) </td>
          <td>Calorie: 13 Kcal CHO: 3.1 gm Protein: 0.1 gm Fat: 0.0 gm</td>
          <td>Refreshing detox water is a great way to hydrate and support your body's natural detoxification</td>
        </tr>
        </tbody>
    </table>


  </body>

</html>
  ''';
}
