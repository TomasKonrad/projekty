// ─── Enumerace ────────────────────────────────────────────────────────────────

export enum AnimalCategory {
  Savci = 'savci',
  Ptaci = 'ptaci',
  Plazi = 'plazi',
  Ryby = 'ryby',
  Obojzivelnici = 'obojzivelnici',
  Hmyz = 'hmyz',
  Pavoukovci = 'pavoukovci',
  Mekkysci = 'mekkysci',
}

export enum AnimalRegion {
    Afrika          = 'afrika',
    JizniAmerika    = 'jizniamerika',
    SeverniAmerika  = 'severniamerika',
    Evropa          = 'evropa',
    Asie            = 'asie',
    Oceanie       = 'oceanie',
    CeskaRepublika  = 'ceskarepublika',
}

export enum ConservationStatus {
  Obnoven = 'obnoven',
  Zranitelny = 'zranitelny',
  Ohrozeny = 'ohrozeny',
  KritickyOhrozeny = 'kriticky_ohrozeny',
}

// ─── Hlavní model ─────────────────────────────────────────────────────────────

export interface Animal {
  id: number | string
  name: string           // český název, např. "Lev africký"
  latinName: string      // latinský název, např. "Panthera leo"
  category: AnimalCategory
  animalRegion: AnimalRegion
  conservationStatus: ConservationStatus
  imageUrl: string
  description: string
  weight?: string        // např. "120–250 kg"
  lifespan?: string      // např. "10–14 let"
  diet?: string          // např. "Masožravec"
  region?: string        // zeměpisný výskyt
}

// ─── Filtrační model ──────────────────────────────────────────────────────────

export interface AnimalFilters {
  search: string
  categories: AnimalCategory[]
  animalRegions: AnimalRegion[]
  conservationStatuses: ConservationStatus[]
}

// ─── API odpovědi (připraveno na reálné API) ──────────────────────────────────

export interface AnimalsApiResponse {
  data: Animal[]
  total: number
  page: number
  perPage: number
}

export interface AnimalApiResponse {
  data: Animal
}

// ─── Lokalizační mapy (label pro UI) ─────────────────────────────────────────

export const CATEGORY_LABELS: Record<AnimalCategory, string> = {
  [AnimalCategory.Savci]: 'Savci',
  [AnimalCategory.Ptaci]: 'Ptáci',
  [AnimalCategory.Plazi]: 'Plazi',
  [AnimalCategory.Ryby]: 'Ryby',
  [AnimalCategory.Obojzivelnici]: 'Obojživelníci',
  [AnimalCategory.Hmyz]: 'Hmyz',
  [AnimalCategory.Pavoukovci]: 'Pavoukovci',
  [AnimalCategory.Mekkysci]: 'Měkkýši',
}

export const REGION_LABELS: Record<AnimalRegion, string> = {
    [AnimalRegion.Afrika]:         'Afrika',
    [AnimalRegion.JizniAmerika]:   'Jižní Amerika',
    [AnimalRegion.SeverniAmerika]: 'Severní Amerika',
    [AnimalRegion.Evropa]:         'Evropa',
    [AnimalRegion.Asie]:           'Asie',
    [AnimalRegion.Oceanie]:      'Austrálie a Oceánie',
    [AnimalRegion.CeskaRepublika]: 'Česká republika',
}

export const CONSERVATION_LABELS: Record<ConservationStatus, string> = {
  [ConservationStatus.Obnoven]: 'Obnoven',
  [ConservationStatus.Zranitelny]: 'Zranitelný',
  [ConservationStatus.Ohrozeny]: 'Ohrožený',
  [ConservationStatus.KritickyOhrozeny]: 'Kriticky ohrožený',
}

export const CONSERVATION_BADGE_CLASS: Record<ConservationStatus, string> = {
  [ConservationStatus.Obnoven]: 'badge-success',
  [ConservationStatus.Zranitelny]: 'badge-warning',
  [ConservationStatus.Ohrozeny]: 'badge-danger',
  [ConservationStatus.KritickyOhrozeny]: 'badge-dark-danger',
}
