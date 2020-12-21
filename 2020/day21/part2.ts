import * as fs from 'fs';
import * as array from 'extra-array';

const recipes: Array<[ Array<string>, Array<string> ]> = []
const all_ingredients: Array<string> = []
const all_allergens: Array<string> = []

const lines = fs.readFileSync(0, 'utf8').split('\n');
for (let line of lines) {
    const groups: RegExpMatchArray | null = line.trim().match('^([a-z ]+)\\s*\\(\\s*contains\\s+([a-z, ]+)\\)$')
    if (groups != null) {
        const ingredients = groups[1].split(' ').map(s => s.trim()).filter(s => s != '')
        const allergens = groups[2].split(',').map(s => s.trim()).filter(s => s != '')
        recipes.push([ ingredients, allergens ])
        for (let ingredient of ingredients) {
            if (!all_ingredients.includes(ingredient)) {
                all_ingredients.push(ingredient);
            }
        }
        for (let allergen of allergens) {
            if (!all_allergens.includes(allergen)) {
                all_allergens.push(allergen);
            }
        }
    }
}

const may_conatain: Record<string, Array<string>> = {}

for (let recipe of recipes) {
    for (let allergen of recipe[1]) {
        if (allergen in may_conatain) {
            may_conatain[allergen] = array.intersection(may_conatain[allergen], recipe[0])
        } else {
            may_conatain[allergen] = Array.from(recipe[0])
        }
    }
}

const contain: Record<string, string> = {}

while (Object.keys(may_conatain).length > 0) {
    for (let allergen in may_conatain) {
        if (may_conatain[allergen].length == 1) {
            contain[allergen] = may_conatain[allergen][0]
            delete may_conatain[allergen]
            for (let x in may_conatain) {
                may_conatain[x] = may_conatain[x].filter(ingredient => ingredient != contain[allergen])
            }
        }
    }
}

const sorted_allergens = Object.keys(contain).sort()
let output = ''
for (let key of sorted_allergens) {
    if (output.length > 0) {
        output += ','
    }
    output += contain[key]
}

console.log(output)