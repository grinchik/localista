MEMORY_SIZE:=4G
CORE_NUMBER:=4

QCOW2_XZ_IMAGE_FILE_NAME:=fedora-coreos-41.20241109.3.0-qemu.aarch64.qcow2.xz
BOOT_IMAGE_FILE_NAME=$(QCOW2_XZ_IMAGE_FILE_NAME:%.xz=%)

BUTANE_CONFIG_FILE_NAME:=localista.bu
IGNITION_CONFIG_FILE_NAME=$(BUTANE_CONFIG_FILE_NAME:%.bu=%.ign)

VAR_IMAGE_FILE_NAME:=var.qcow2
VAR_IMAGE_FORMAT:=qcow2
VAR_IMAGE_SIZE:=16G

EFI_IMAGE_FILE_PATH:=/opt/homebrew/share/qemu/edk2-aarch64-code.fd

SSH_AUTHORIZED_KEY_FILE_NAME:=id_ed25519.pub

.PHONY: _
_:

.PHONY: clean
clean: \
	/
	rm -f $(IGNITION_CONFIG_FILE_NAME);
	rm -f $(BOOT_IMAGE_FILE_NAME);
	rm -f $(SSH_AUTHORIZED_KEY_FILE_NAME);

$(SSH_AUTHORIZED_KEY_FILE_NAME): \
	/
	cp \
		-v \
		~/.ssh/$(SSH_AUTHORIZED_KEY_FILE_NAME) \
		. \
		;

$(IGNITION_CONFIG_FILE_NAME): \
	$(BUTANE_CONFIG_FILE_NAME) \
	$(SSH_AUTHORIZED_KEY_FILE_NAME) \
	/
	butane \
		--files-dir . \
		--pretty \
		--strict \
		< $(BUTANE_CONFIG_FILE_NAME) \
		> $(IGNITION_CONFIG_FILE_NAME) \
		;

$(BOOT_IMAGE_FILE_NAME): \
	$(QCOW2_XZ_IMAGE_FILE_NAME) \
	/
	xz \
		--decompress \
		--keep \
		--verbose \
		$(QCOW2_XZ_IMAGE_FILE_NAME) \
		;

$(VAR_IMAGE_FILE_NAME): \
	/
	qemu-img \
		create \
			-f $(VAR_IMAGE_FORMAT) \
			$(VAR_IMAGE_FILE_NAME) \
			$(VAR_IMAGE_SIZE) \
		;

.PHONY: localista
localista: \
	$(BOOT_IMAGE_FILE_NAME) \
	$(VAR_IMAGE_FILE_NAME) \
	$(IGNITION_CONFIG_FILE_NAME) \
	/
	qemu-system-aarch64 \
		-m $(MEMORY_SIZE) \
		-smp $(CORE_NUMBER) \
		-cpu host \
		-machine virt \
		-accel hvf \
		\
		-drive if=pflash,file=$(EFI_IMAGE_FILE_PATH),format=raw,readonly=on \
		-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG_FILE_NAME} \
		\
		-drive if=none,file=$(BOOT_IMAGE_FILE_NAME),snapshot=on,id=BOOT-DISK \
		-device virtio-blk-pci,drive=BOOT-DISK \
		\
		-drive file=$(VAR_IMAGE_FILE_NAME),if=none,id=VAR-DISK \
		-device virtio-blk-pci,drive=VAR-DISK,serial=VAR-DISK \
		\
		-nic user,model=virtio\
,hostfwd=tcp::2222-:22\
		\
		-nographic \
		;
