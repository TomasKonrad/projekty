export interface WikipediaSummaryResponse {
    title: string;
    extract: string; // Textový souhrn
    description?: string; // Může sloužit jako podtitulek (např. "Druh savce")
    thumbnail?: {
        source: string; // URL obrázku
        width: number;
        height: number;
    };
    originalimage?: {
        source: string;
    };
}