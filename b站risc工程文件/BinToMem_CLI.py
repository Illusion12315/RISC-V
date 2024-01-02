import sys
import os


def getFilePathList(path, filetype):
    pathList = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(filetype):
                pathList.append(os.path.join(root, file))
    return pathList

def bin_to_mem(infile, outfile):
    binfile = open(infile, 'rb')
    binfile_content = binfile.read(os.path.getsize(infile))
    datafile = open(outfile, 'w')

    index = 0
    b0 = 0
    b1 = 0
    b2 = 0
    b3 = 0

    for b in  binfile_content:
        if index == 0:
            b0 = b
            index = index + 1
        elif index == 1:
            b1 = b
            index = index + 1
        elif index == 2:
            b2 = b
            index = index + 1
        elif index == 3:
            b3 = b
            index = 0
            array = []
            array.append(b3)
            array.append(b2)
            array.append(b1)
            array.append(b0)
            datafile.write(bytearray(array).hex() + '\n')

    binfile.close()
    datafile.close()

def create_all_inst():
    print("start")
    path = ".\\inst_txt"
    bin_path = '.\\generated'

    file = getFilePathList(bin_path, 'bin')
    if not os.path.exists(path):
        os.makedirs(path)

    for bin_file in file:
        print(bin_file)
        mem_file = bin_file.replace('.bin', '.txt')
        mem_file = mem_file.replace(bin_path, path)
        bin_to_mem(bin_file, mem_file)
        print(mem_file)


    print("create succed")


if __name__ == '__main__':
    create_all_inst()
    # if len(sys.argv) == 3:
    #     bin_to_mem(sys.argv[1], sys.argv[2])
    # else:
    #     print('Usage: %s binfile datafile' % sys.argv[0], sys.argv[1], sys.argv[2])
