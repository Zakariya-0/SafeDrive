package com.safedrive.servlet;

import com.safedrive.model.Accident;
import com.safedrive.model.Vehicle;
import com.safedrive.service.AccidentService;
import com.safedrive.service.VehicleService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.pdmodel.font.PDType1Font;
import org.apache.pdfbox.pdmodel.font.Standard14Fonts;

import java.awt.Color;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/app/reports")
public class ReportServlet extends HttpServlet {

    private final AccidentService accidentService = new AccidentService();
    private final VehicleService  vehicleService  = new VehicleService();

    private static final DateTimeFormatter FMT =
            DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    // ── Layout constants (A4 points) ─────────────────────────────────────────
    private static final float MARGIN    = 40f;
    private static final float PAGE_W    = PDRectangle.A4.getWidth();   // 595.28
    private static final float PAGE_H    = PDRectangle.A4.getHeight();  // 841.89
    private static final float USABLE_W  = PAGE_W - 2 * MARGIN;        // 515.28
    private static final float ROW_H     = 20f;
    private static final float PAD       = 4f;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String role          = (String) req.getAttribute("currentRole");
        Long   currentUserId = (Long)   req.getAttribute("currentUserId");
        String type          = req.getParameter("type");

        if ("accidents".equals(type)) {
            boolean isDriver = "DRIVER".equals(role);
            List<Accident> list = isDriver
                    ? accidentService.getAccidentsByDriver(currentUserId)
                    : accidentService.getAllAccidents();
            String filename = isDriver ? "mes_accidents.pdf" : "rapport_accidents.pdf";
            String title    = isDriver ? "SafeDrive — Mes Accidents"
                                       : "SafeDrive — Rapport des Accidents";
            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=" + filename);
            buildAccidentPdf(list, title, resp);

        } else if ("accident-single".equals(type)) {
            if ("DRIVER".equals(role)) { resp.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
            String idParam = req.getParameter("id");
            if (idParam == null || idParam.isBlank()) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST); return; }
            Long id = Long.parseLong(idParam);
            Accident a = accidentService.findByIdWithDetails(id).orElse(null);
            if (a == null) { resp.sendError(HttpServletResponse.SC_NOT_FOUND); return; }
            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=accident_" + id + ".pdf");
            buildAccidentPdf(List.of(a), "SafeDrive — Rapport d'Accident #" + id, resp);

        } else if ("vehicles".equals(type)) {
            if ("DRIVER".equals(role)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=rapport_vehicules.pdf");
            buildVehiclePdf(vehicleService.getAllVehicles(), resp);

        } else {
            req.getRequestDispatcher("/WEB-INF/views/reports.jsp").forward(req, resp);
        }
    }

    // ── PDF builders ─────────────────────────────────────────────────────────

    private void buildAccidentPdf(List<Accident> list, String title,
                                   HttpServletResponse resp) throws IOException {
        String[] headers = {"#", "Chauffeur", "Vehicule", "Date", "Lieu", "Severite", "Statut"};
        float[]  widths  = {28, 95, 100, 65, 117, 63, 47};

        try (PDDocument doc = new PDDocument()) {
            TableBuilder tb = new TableBuilder(doc, title, headers, widths);
            for (Accident a : list) {
                tb.row(
                    String.valueOf(a.getId()),
                    a.getDriver().getFirstName() + " " + a.getDriver().getLastName(),
                    a.getVehicle().getBrand() + " " + a.getVehicle().getModel(),
                    a.getDate().toString(),
                    a.getLocation() != null ? a.getLocation() : "-",
                    a.getSeverity().name(),
                    a.getStatus().name()
                );
            }
            tb.close();
            doc.save(resp.getOutputStream());
        }
    }

    private void buildVehiclePdf(List<Vehicle> list,
                                  HttpServletResponse resp) throws IOException {
        String[] headers = {"Immatriculation", "Marque", "Modele", "Annee", "Kilometrage", "Statut"};
        float[]  widths  = {100, 85, 85, 50, 90, 105};

        try (PDDocument doc = new PDDocument()) {
            TableBuilder tb = new TableBuilder(doc,
                    "SafeDrive — Rapport des Vehicules", headers, widths);
            for (Vehicle v : list) {
                tb.row(
                    v.getRegistrationNumber(),
                    v.getBrand()  != null ? v.getBrand()  : "",
                    v.getModel()  != null ? v.getModel()  : "",
                    v.getYear()   != null ? v.getYear().toString() : "",
                    v.getMileage() + " km",
                    v.getStatus().name()
                );
            }
            tb.close();
            doc.save(resp.getOutputStream());
        }
    }

    // ── Inner table builder ───────────────────────────────────────────────────

    private static final class TableBuilder {

        private static final Color HDR_BG  = new Color(52,  58,  64);
        private static final Color ROW_ALT = new Color(248, 249, 250);
        private static final Color GRID    = new Color(222, 226, 230);
        private static final Color TXT     = new Color(33,  37,  41);
        private static final Color TXT_SUB = new Color(108, 117, 125);

        private final PDDocument     doc;
        private final String[]       headers;
        private final float[]        widths;
        private final PDType1Font    fontBold;
        private final PDType1Font    fontNormal;

        private PDPage              page;
        private PDPageContentStream cs;
        private float               y;
        private int                 rowIdx = 0;

        TableBuilder(PDDocument doc, String title,
                     String[] headers, float[] widths) throws IOException {
            this.doc       = doc;
            this.headers   = headers;
            this.widths    = widths;
            this.fontBold   = new PDType1Font(Standard14Fonts.FontName.HELVETICA_BOLD);
            this.fontNormal = new PDType1Font(Standard14Fonts.FontName.HELVETICA);
            openPage();
            writeTitle(title);
            writeHeaderRow();
        }

        private void openPage() throws IOException {
            if (cs != null) cs.close();
            page = new PDPage(PDRectangle.A4);
            doc.addPage(page);
            cs = new PDPageContentStream(doc, page);
            y  = PAGE_H - MARGIN;
        }

        private void writeTitle(String title) throws IOException {
            cs.beginText();
            cs.setFont(fontBold, 16);
            cs.setNonStrokingColor(TXT);
            cs.newLineAtOffset(MARGIN, y - 18);
            cs.showText(ascii(title));
            cs.endText();
            y -= 32;

            cs.beginText();
            cs.setFont(fontNormal, 8);
            cs.setNonStrokingColor(TXT_SUB);
            cs.newLineAtOffset(MARGIN, y - 8);
            cs.showText("Genere le : " + LocalDateTime.now().format(FMT));
            cs.endText();
            y -= 22;
        }

        private void writeHeaderRow() throws IOException {
            cs.setNonStrokingColor(HDR_BG);
            cs.addRect(MARGIN, y - ROW_H, USABLE_W, ROW_H);
            cs.fill();

            cs.setNonStrokingColor(Color.WHITE);
            float x = MARGIN;
            for (int i = 0; i < headers.length; i++) {
                putText(ascii(headers[i]), x, y, widths[i], fontBold, 8.5f);
                x += widths[i];
            }
            grid(y);
            y -= ROW_H;
        }

        void row(String... cells) throws IOException {
            if (y - ROW_H < MARGIN + 30) {
                openPage();
                writeHeaderRow();
            }
            if (rowIdx % 2 == 0) {
                cs.setNonStrokingColor(ROW_ALT);
                cs.addRect(MARGIN, y - ROW_H, USABLE_W, ROW_H);
                cs.fill();
            }
            cs.setNonStrokingColor(TXT);
            float x = MARGIN;
            for (int i = 0; i < cells.length; i++) {
                putText(ascii(cells[i]), x, y, widths[i], fontNormal, 8f);
                x += widths[i];
            }
            grid(y);
            y -= ROW_H;
            rowIdx++;
        }

        void close() throws IOException {
            if (cs != null) { cs.close(); cs = null; }
        }

        // ── helpers ──────────────────────────────────────────────────────────

        private void putText(String text, float cx, float cy,
                              float colW, PDType1Font font, float size)
                throws IOException {
            String t = clip(text, font, size, colW - 2 * PAD);
            cs.beginText();
            cs.setFont(font, size);
            cs.newLineAtOffset(cx + PAD, cy - ROW_H + PAD + 2);
            cs.showText(t);
            cs.endText();
        }

        private void grid(float topY) throws IOException {
            cs.setStrokingColor(GRID);
            cs.setLineWidth(0.4f);
            cs.moveTo(MARGIN, topY - ROW_H);
            cs.lineTo(MARGIN + USABLE_W, topY - ROW_H);
            cs.stroke();
            float x = MARGIN;
            cs.moveTo(x, topY); cs.lineTo(x, topY - ROW_H); cs.stroke();
            for (float w : widths) {
                x += w;
                cs.moveTo(x, topY); cs.lineTo(x, topY - ROW_H); cs.stroke();
            }
            cs.setStrokingColor(Color.BLACK);
        }

        private String clip(String text, PDType1Font font, float size, float maxW) {
            if (text == null || text.isEmpty()) return "";
            try {
                if (font.getStringWidth(text) / 1000f * size <= maxW) return text;
                int n = text.length();
                while (n > 0) {
                    String s = text.substring(0, n) + "...";
                    if (font.getStringWidth(s) / 1000f * size <= maxW) return s;
                    n--;
                }
                return "";
            } catch (Exception e) {
                int max = Math.max(0, (int)(maxW / (size * 0.55f)));
                return text.length() > max ? text.substring(0, max) : text;
            }
        }

        /** Keep only characters safely encodable by PDType1Font/WinAnsiEncoding. */
        private static String ascii(String s) {
            if (s == null) return "";
            StringBuilder sb = new StringBuilder(s.length());
            for (char c : s.toCharArray()) {
                if      (c < 0x20)            continue;       // control
                else if (c >= 0x80 && c < 0xA0) sb.append('?'); // Windows-1252 specials
                else if (c > 0xFF)             sb.append('?'); // beyond Latin-1
                else                           sb.append(c);
            }
            return sb.toString();
        }
    }
}
