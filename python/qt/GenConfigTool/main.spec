# -*- mode: python -*-

block_cipher = None

  
a = Analysis(['main.py'],
             pathex=['D:\\Documents\\GitHub\\dzr_code_2017\\python\\qt\\GenConfigTool'],
             binaries=[],
             datas=[],
             hiddenimports=['PyQt5.sip'],
             hookspath=[],
             runtime_hooks=[],
             excludes=['_socket', '_ssl', '_hashlib', 'PyQt5.QtPrintSupport'],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)

exclude_dll = ['Qt5Network.dll', 'Qt5Qml.dll', 'Qt5Svg.dll', 'Qt5Quick.dll', 'Qt5WebSockets.dll']
a.binaries = [x for x in a.binaries if x[0] not in exclude_dll]
# print(a.binaries)

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='main',
          debug=False,
          strip=False,
          upx=True,
          icon="icon.ico",
          runtime_tmpdir=None,
          console=False )

COLLECT(
        exe,
        strip=False,
        upx=True,
        name='main')
