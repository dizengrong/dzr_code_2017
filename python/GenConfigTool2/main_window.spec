# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['main_window.py'],
             pathex=['F:\\work\\my_github\\dzr_code\\python\\GenConfigTool2'],
             binaries=[],
             datas=[],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)

exclude_dll = ['Qt5Network.dll', 'Qt5Qml.dll', 'Qt5Svg.dll', 'Qt5Quick.dll', 'Qt5WebSockets.dll']
a.binaries = [x for x in a.binaries if x[0] not in exclude_dll]

exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          [],
          name='tpl_generator',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          icon="ico.ico",
          upx_exclude=[],
          runtime_tmpdir=None,
          console=False )

COLLECT(
        exe,
        strip=False,
        upx=True,
        name='tpl_generator')