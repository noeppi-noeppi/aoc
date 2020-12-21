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

const no_allergen = except(all_ingredients, Object.values(may_conatain))

let amount = 0
for (let recipe of recipes) {
    for (let ingredient of no_allergen) {
        if (recipe[0].includes(ingredient)) {
            amount += 1
        }
    }
}

console.log(amount)

function except<T>(elems: Array<T>, lists: Array<Array<T>>): Array<T> {
    if (lists.length > 0) {
        const except: Array<T> = Array.from(elems);
        for (let list of lists) {
            const removeIndices: Array<number> = []
            for (let idxStr in except) {
                const idx = parseInt(idxStr)
                if (!removeIndices.includes(idx) && list.includes(except[idx])) {
                    removeIndices.push(idx)
                }
            }
            const sortedIndices = removeIndices.sort().reverse()
            for (let idx of sortedIndices) {
                except.splice(idx, 1)
            }
        }
        return except
    } else {
        return Array.from(elems)
    }
}