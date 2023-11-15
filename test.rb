require "google_drive"


class Column
    include Enumerable

    @table
    def initialize(arr)
        #head, tail* = arr
        @name, *@content = arr
    end

    def return_content()
        @content
    end

    def length()
        return @content.length
    end

    def [](x)
        @content[x - 1]
    end

    def []= (x, value)
        @content[x - 1] = value
    end

    def sum
        suma = 0
        @content.each{|x| suma += x.to_i()}
        return suma
    end

    def avg
        sum = 0
        count = 0
        @content.each{|x| sum += x.to_i() }
        @content.each{|x| count += 1 }
        return sum * 1.0 / count
    end

    def method_missing(m, *args, &block)
        f = m.to_s()
        indeks = 1
        @content.each do |xd|
            if xd == f then
                break
            end
            indeks +=1
        end
            
        red = []
        i = 0
        @table.return_matrica().each do |blok|
            if i == indeks then
                red = blok
            end
            i+=1
        end
        return red
    end

    def append(value)
        @content.append(value)
    end

    def delete(indeks)
        @content.delete_at(indeks)
    end
    def name()
        @name
    end

    def table(table)
        @table = table
    end

    def each
        @content.each {|block| yield block}
    end
end

class Table
    include Enumerable

    def initialize(kolone)
        @kolone = kolone
        @kolone.each {|b| b.table(self)}
    end
    def row(index)
        red = []
        @kolone.each do |kolona|
            red.append(kolona.return_content[index])
        end
        return red
    end

    def return_matrica()
        matrica = []
        niz = []
        @kolone.each do |kolona|
            niz.append(kolona.name())
        end
        matrica.append(niz)
        (0..@kolone[0].length()-1).each do |indeks|
            niz = []
            @kolone.each do |kolona|
                niz.append(kolona.return_content[indeks])
            end
            matrica.append(niz)
        end
        return matrica
    end

    def [](x)
        ret = nil
        @kolone.each do |kolona|
            if kolona.name() == x
                ret = kolona
                break
            end
        end
        return ret
    end

    def each(&block)
        matrica = return_matrica()
        n = matrica.length
        m = matrica[0].length

        (0..n-1).each do |row|
            (0..m-1).each do |col|
                block.call(matrica[row][col])
            end
        end
    end

    def method_missing(m, *args, &block)
        kol = m.to_s().downcase
        col = nil
        @kolone.each do |kolona|
            if kol == kolona.name().gsub(/\s+/, "").downcase
                col = kolona
                break
            end
        end
        return col
    end

    def return_kolone()
        @kolone
    end
    def + (obj)
        flag = true
        k = 0

        while k < @kolone.length
            if @kolone[k].name != obj.return_kolone()[k].name
                flag = false
                break
            end
            k+=1
        end

        if flag
            x = 0
            @kolone.each do |kolona|
                obj.return_kolone()[x].return_content().each do |d|
                        kolona.append(d)
                end
                x+=1
            end
        end
    end

    def - (obj)
        matrica1 = return_matrica()
        matrica2 = obj.return_matrica()
        if(matrica1[0] != matrica2[0])
            return
        end
        x = 0
        nz = []
        matrica1.each do |red1|
            matrica2.each do |red2|
                if red1 == red2
                    nz.append(x)
                end
            end
            x+=1
        end
        p nz
        nz.delete(0)
        @kolone.each do |mast|
            l = 0
            nz.each do |i|
                mast.delete(i-1-l)
                l += 1
            end
        end
    end

end
# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
# See this document to learn how to create config.json:
# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md

def findTable(index)
    session = GoogleDrive::Session.from_config("config.json")

    ws = session.spreadsheet_by_key("1xchQiYX9QE2tyr6UZLlB65Y3Pwv3ThOhMRlklQCB4DM").worksheets[index]

    matrica = []
    i = 0
    j = 0

    ddx = false
    (1..ws.num_rows).each do |row|
        if ddx then
            break
        end
        (1..ws.num_cols).each do |col|
           if ws[row, col] != "" then
                i = row
                j = col
                ddx = true
            break
            end
        end
    end

    n = 0
    m = 0
    ddx = false
    (1..ws.num_rows).reverse_each do |row|
        if ddx then
            break
        end
        (1..ws.num_cols).reverse_each do |col|
            if ws[row, col] != "" then
                n = row
                m = col
                ddx = true
                break
            end
        end
    end

    matrica = []
    (i..n).each do |row|
        xd = []
        (j..m).each do |col|
          xd.append(ws[row, col])
        end
        matrica.append(xd)
    end
    return matrica
end

def createColumns(table)
    n = table.length
    m = table[0].length

    ind = []
    (0..n-1).each do |row|
        flag = false
        (0..m-1).each do |col|
          if table[row][col] != "" then
            flag = true
            #p row, col
            break
          end
        end
        if !flag then
            ind.append(row)
        end
    end 
    it = 0
    ind.each do |index|
        table.delete_at(index - it)
        it+=1
    end

    #total i subtotal
    n = table.length
    m = table[0].length
    ind = []
    (0..n-1).each do |row|
        (0..m-1).each do |col|
            if table[row][col] == "subtotal" then
                ind.append(row)
            elsif table[row][col] == "total" then
                ind.append(row)
            end
        end
    end

    it = 0
    ind.each do |index|
        table.delete_at(index - it)
        it+=1
    end

    columns = table.transpose
    kolone = []
    columns.each do |column|
        kolone.append(Column.new(column))
    end
    #pp kolone
    return kolone
end

#ucitavanje tabele
table = findTable(0)
kolone = createColumns(table)
t1 = Table.new(kolone)

#ucitavanje druge tabele
table2 = findTable(1)
kolone2 = createColumns(table2)
t2 = Table.new(kolone2)

t1.each {|x| p x}

p t1.row(0)

p t1["Prva kolona"]

t1["Prva kolona"][0] = 17
p "izmenjena kolona", t1["Prva kolona"][0]

p "search", t1.drugaKolona.lule

p "map: ", t1.prvaKolona.map {|x| x = x.to_i + 1}

p "avg: ", t1.trecaKolona.avg

p "sum: ", t1.trecaKolona.sum

t1+t2
pp "sabrane tabele: ", t1.return_matrica()

t1-t2
pp "oduzete tabele: ", t1.return_matrica()


