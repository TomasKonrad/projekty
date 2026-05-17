
export interface Monster {
    id: string;
    name: string;
    age: number;
    hasFur: boolean;
    avatar: string;
}

export interface Filters {
    needFur: boolean;
    minAge: number;
    maxAge: number;
}

export type SwipeDirection = 'left' | 'right';